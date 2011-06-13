From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 37172] New: Enabling 802.1q vlan causes some
 packets to be received with a vlan id of 64
Date: Mon, 13 Jun 2011 16:43:55 -0700
Message-ID: <20110613164355.c4f7b7b2.akpm@linux-foundation.org>
References: <bug-37172-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: a.reversat@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37374 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753625Ab1FMXoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 19:44:06 -0400
In-Reply-To: <bug-37172-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 10 Jun 2011 19:20:58 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=37172
> 
>            Summary: Enabling 802.1q vlan causes some packets to be
>                     received with a vlan id of 64
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: a.reversat@gmail.com
>         Regression: Yes

>From which kernel version did we regress?  Was 2.6.38 OK?

Thanks.

> 
> Created an attachment (id=61502)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=61502)
> Packet capture of problem
> 
> I added a vlan to my main network card by doing :
> 
> vconfig add eth0 6
> 
> Then I got huge packet loss when pinging e.g google (around 70% packet loss).
> 
> After checking a packet capture it seems that some packets come in with a vlan
> tag even though they shouldn't. In my capture I see them with a vlan id of 64
> where they shouldn't even be 802.1q tagged.
> 
> Kernel version is 2.6.39 and I am using the forcedeth driver so I don't know if
> it is related to the network stack or the forcedeth driver.
> 
> Attached is the relevant capture. Note how packet with seq 2 for instance is
> tagged and packet with seq 5 isn't.
> 
> I'll test this with the latest 3.0 rc and update the bug report if the problem
> is fixed in there.
> 



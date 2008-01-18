From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9773] New: pptp/ppp connection die at high
 speed on Athlon X2 6000+
Date: Thu, 17 Jan 2008 23:48:09 -0800
Message-ID: <20080117234809.fc3f6cca.akpm@linux-foundation.org>
References: <bug-9773-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Paul Mackerras <paulus@samba.org>, wizard580@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50906 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753403AbYARHrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 02:47:55 -0500
In-Reply-To: <bug-9773-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 23:33:54 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9773
> 
>            Summary: pptp/ppp connection die at high speed on Athlon X2 6000+
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23.12
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: wizard580@gmail.com
> 
> 
> Distribution: debian sid, vanilla kernel
> Hardware Environment: Athlon64 X2 6000+ Nforce5
> Software Environment: pptp 1.7.0 pppd 2.4.4
> 
> Problem Description:
> when I download data at high speed (1,5 MB/s or more) connection (pptp dies)
> drops and reconnect begins (persist option used for pppd) and after reconnect
> it dies again and again. connection made by "pppd call provider"
> 
> before upgrade of hardware (was Athlon64 3500+ NForce4) all works fine at any
> speed.
> 
> Connection will be working if I do some CPU aggressive work such as kernel
> compile at the same time when I download. When CPU load become low it will drop
> again.
> 
> kernel 2.6.24rc8 makes it worst. As I see it just hangs my console with message
> something like "waiting for ppp0 finish" or so... I don't remember exactly
> message.
> 
> 
> Steps to reproduce:
> I think you can use any X2 Athlon, make pptp connection and try to download
> something...

(weird)

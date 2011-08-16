From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to
 handle vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Tue, 16 Aug 2011 15:09:18 -0700
Message-ID: <20110816150918.5b2d7067.akpm@linux-foundation.org>
References: <bug-41152-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	mike.auty@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52261 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751485Ab1HPWJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 18:09:52 -0400
In-Reply-To: <bug-41152-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 14 Aug 2011 12:48:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=41152
> 
>            Summary: kernel 3.0 and above fails to handle vlan id 0
>                     (802.1p) packets properly without hardware
>                     acceleration
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.0
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: mike.auty@gmail.com
>         Regression: Yes
> 
> 
> Hi there,
> 
> I recently found that packets tagged with a vlan id of 0 are no longer received
> on the main interface.  There were no dmesg entries on the dropped packets.  I
> attempted to setup a vlan 0 interface and configure it, but couldn't
> successfully route traffic to the device.  I can recreate this on two of the
> three networking devices I have, my guess is that the third does successfully
> handle hardware acceleration of vlan tags. 
> 
> After a bisection this appears to be related to commit
> bcc6d47903612c3861201cc3a866fb604f26b8b2, which seems to try to merge the
> non-hardware accelerated and hardware accelerated code paths for handling
> vlans.  In the process, it appears vlan id 0 (802.1p) packets are no longer
> handled correctly.
> 
> Unfortunately I don't know the code paths well enough to figure out what's
> going wrong, but I'd be happy to provide more information, run tests or try out
> patches if it would help, just let me know.  Thanks...  5:)
> 
> Mike  5:)


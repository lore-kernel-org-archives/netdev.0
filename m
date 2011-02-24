From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 29562] New: Kernel Panic with b44 eth-module
 (Kernel 2.6.37) | Dell Vostro 1500
Date: Wed, 23 Feb 2011 16:12:01 -0800
Message-ID: <20110223161201.f49f51e4.akpm@linux-foundation.org>
References: <bug-29562-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	ck.accounts@gmx.de
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43698 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662Ab1BXANK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 19:13:10 -0500
In-Reply-To: <bug-29562-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 21 Feb 2011 09:35:59 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=29562
> 
>            Summary: Kernel Panic with b44 eth-module (Kernel 2.6.37) |
>                     Dell Vostro 1500
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.37.1 (ArchLinux latest)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ck.accounts@gmx.de
>         Regression: No
> 
> 
> Hey,
> 
> I have a problem with my network card (b44 driver). It's almost the same
> problem described here:
> https://bugzilla.redhat.com/show_bug.cgi?id=668088
> 
> I think it's a common Dell problem. I found several Dell users with the same
> problem. The problem occured first with the kernel update to 2.6.37 (2.6.36.x
> -> 2.6.37)
> 
> I have taken a picture of the panic-log:
> http://www.pic-upload.de/view-8728232/DSC00735.jpg.html
> 
> The workaround for this issue is to block the module !b44 (-> network card
> doesn't work anymore).
> 
> Some additional information:
> Laptop: Dell Vostro 1500
> Distro: ArchLinux x86_64
> Ethernet controler: 03:00.0 Ethernet controller: Broadcom Corporation
> BCM4401-B0 100Base-TX (rev 02)
> 
> 1. boot PC without b44
> 2. # modprobe b44
> 3. kernel panic!
> 
> I am not sure, whether it is a ArchLinux problem or a general kernel problem?
> 


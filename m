From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14791] New: Something has been broken in the
 network stack this week
Date: Wed, 16 Dec 2009 15:40:18 -0800
Message-ID: <20091216154018.e3baaed6.akpm@linux-foundation.org>
References: <bug-14791-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, speedyboyinovator@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42488 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933398AbZLPXkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 18:40:21 -0500
In-Reply-To: <bug-14791-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Said to be a post-2.6.32 regression.

On Sat, 12 Dec 2009 13:06:04 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14791
> 
>            Summary: Something has been broken in the network stack this
>                     week
>            Product: Networking
>            Version: 2.5
>     Kernel Version: after 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: speedyboyinovator@hotmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=24161)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24161)
> dmesg and lspci outputs
> 
> Apparently something has been broken in the network stack this week
> 
> Hi. This is my first bug/issue report, so understand any mistake or n00b thing
> I make here. And sorry for the bad english ;)
> 
> It looks like that from the 2.6.32 release, to the git commit
> 2.6.32-05254-g3067e02 (i've compiled it in Dec 10 11:39:26 (Brazilian TZ)
> 2009), something weird happened ;)
> 
> I've used the USB_NET_CDCETHER for 2 years now, and it always worked.
> But when I rebooted to my new kernel 2.6.32-05254-g3067e02, from the 2.6.32, it
> just dont get connected.
> 
> [   16.683465] ADDRCONF(NETDEV_UP): eth1: link is not ready
> [   94.854539] ADDRCONF(NETDEV_UP): eth1: link is not ready
> 
> There's no symptom of anything wrong. And even restarting the modem and then
> reconnecting the USB cable, it does'nt work.
> 
> Then I reboot to the 2.6.32 one, and it takes just one dhclient command and 1
> second to be online again.
> 
> 
> ---- output of: sh scripts/ver_linux
> 
> Linux speedyb0y 2.6.32speedyb0y-05254-g3067e02 #3 PREEMPT Thu Dec 10 11:39:26
> BRST 2009 i686 GNU/Linux
> 
> Gnu C                  4.4.2
> Gnu make               3.81
> binutils               2.20
> util-linux             2.16.2
> mount                  support
> module-init-tools      3.11
> e2fsprogs              1.41.9
> reiserfsprogs          3.6.21
> PPP                    2.4.4
> Linux C Library        2.10.2
> Dynamic linker (ldd)   2.10.2
> Procps                 3.2.8
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               8.1
> Modules Loaded         nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs
> binfmt_misc cdc_ether usbnet
> 
> ---- output of: cat /proc/version 
> 
> Linux version 2.6.32speedyb0y-05254-g3067e02 (speedyb0y@speedyb0y) (gcc version
> 4.4.2 (Debian 4.4.2-3) ) #3 PREEMPT Thu Dec 10 11:39:26 BRST 2009


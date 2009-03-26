From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12946] New: nfs-root fails with commit
 303c6a0251852ecbdc5c15e466dcaff5971f7517
Date: Thu, 26 Mar 2009 07:53:15 -0700
Message-ID: <20090326075315.9aea88cb.akpm@linux-foundation.org>
References: <bug-12946-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, donari75@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60344 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823AbZCZO4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 10:56:41 -0400
In-Reply-To: <bug-12946-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 26 Mar 2009 13:41:52 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12946
> 
>            Summary: nfs-root fails with commit
>                     303c6a0251852ecbdc5c15e466dcaff5971f7517
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.29
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: donari75@gmail.com
>         Regression: Yes
> 
> 
> nfs-root fails with this commit on my pxa270 based custom board.
> network card is SMSC LAN91C111.
> 
> Kernel command line parameters are "console=ttyS0,115200 root=/dev/nfs rw
> nfsroot=192.168.10.240:/home/uskim/work/rootfs/mg-image-minimal-mgpmp,tcp
> ip=dhcp"
> 
> VFS: Mounted root (nfs filesystem) on device 0:14.
> Freeing init memory: 140K
> nfs: server xxx.xxx.xxx.xxx not responding, still trying
> nfs: server xxx.xxx.xxx.xxx not responding, still trying
> nfs: server xxx.xxx.xxx.xxx not responding, still trying
> ...
> 
> I had waited a hour in this state but never come back "nfs OK"
> 
> Sometimes I can login but after some work always get same message
> (approximately within 5 minutes).
> 

Uwe Bugla also has fingered this commit (in his inimitable way) for
causing networking to break.


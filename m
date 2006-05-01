From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6468] New: sky2 driver doesnt work in
 2.6.16-r3, -r4 but was working in 2.6.15-r8
Date: Sun, 30 Apr 2006 18:15:43 -0700
Message-ID: <20060430181543.6e38a842.akpm@osdl.org>
References: <200605010011.k410BCd1023886@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19851 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750793AbWEABRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 21:17:41 -0400
To: a.kulakov@mail.ru
In-Reply-To: <200605010011.k410BCd1023886@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Please resond via reply-to-all, not via the bugzilla UI)

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6468
> 
>            Summary: sky2 driver doesnt work in 2.6.16-r3,-r4 but was working
>                     in 2.6.15-r8
>     Kernel Version: 2.6.16-r4
>             Status: NEW
>           Severity: high
>              Owner: jgarzik@pobox.com
>          Submitter: a.kulakov@mail.ru
> 
> 
> Most recent kernel where this bug did not occur:
> 2.6.15-r8
> 
> Distribution:
> gentoo
> 
> Hardware Environment:
> Asus A38, Pentium-M 2.0GHz, 1024M RAM, Marvell Technology Group Ltd. 88E8053
> PCI-E Gigabit Ethernet Controller (rev 19)
> 
> Problem Description:
> No packets are received by programs while ifconfig counts them. No iptables
> rules in effect and all chans policies set to ACCEPT.
> dhcpcd fails to get response from server. tcpdump doesnt show any incoming
> packets while shows outgoing. ifconfig indicates that both rx and tx get increased!
> 
> That driver was working for me till 2.6.15-r8. It doesn't work with 2.6.16-r3
> nor -r4. I didn't try earlier 2.6.16 kernels but will do that if needed.
> 
> I tried to load module with disable_msi=1 but it didn't make any difference.
> 
> Steps to reproduce:
> modprobe sky2 debug=16
> dhcpcd eth0
> tcpdump -n -i eth0
> 

I assume that when you say "2.6.16-r4" you actually mean "2.6.16-rc4"?  Or
do you mean 2.6.16.4?  It matters rather a lot.

So, please confirm the earliest known-to-be-broken kernel version and the
latest known-to-be-working version, using the correct release
identification, thanks.


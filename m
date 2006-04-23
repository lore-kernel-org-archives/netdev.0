From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6430] New: ipsec tunnel : reply is not
 forwarded
Date: Sun, 23 Apr 2006 12:53:42 -0700
Message-ID: <20060423125342.71a6e0d5.akpm@osdl.org>
References: <200604231526.k3NFQ5dO010175@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: astier.raphael@free.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50149 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751452AbWDWTzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 15:55:00 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200604231526.k3NFQ5dO010175@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6430
> 
>            Summary: ipsec tunnel : reply is not forwarded
>     Kernel Version: 2.6.14.5
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: astier.raphael@free.fr
> 
> 
> Most recent kernel where this bug did not occur: 2.6.14
> Distribution: debian sarge 3.1
> Hardware Environment: 
> Software Environment: isakmpd
> Problem Description: 
> The situation is the following :
> hostA -- GW1 <==> GW2 -- hostB, with an ipsec tunnel between GW1 and GW2.
> Encryption : des-cbc, Auth : hmac-md5, and automatic keyring with isakmpd
> on GW1 and GW2. 
> The tunnel is correctly mounted, with symmetrical spi on both sides GW1 and GW2.
> (I have verified with setkey)
> When hostA ping hostB, packets are correctly send to hostB, and returns
> to GW1, and are decrypted here, but are not forwarded to hostA. 
> (Symmetrically when hostB ping hostA packet returned on GW2 are not 
> forwarded to hostB). I have verified with tcpdump.
> I have try exactly the same configuration with standard kernel 2.6.8 from
> sarge distrib. and it works perfectly.
> I also try to echo 0 > /proc/...eth0/rp_filter where eth0 is the interface on
> GW2  "connected" to GW1 but result is the same.
> I have also try replacing GW2 by a Cisco PIX, and I have same result 
> on linux (2.6.14.5) GW1.
> 
> Steps to reproduce:
> Configure an ipsec tunnel between GW1 and GW2 as described above. I have done 
> it with isakmpd, and with standard support of ipsec in kernel, not with 
> freeswan.
> 

That's quite an old kernel.  Are you able to test 2.6.16?

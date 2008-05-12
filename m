From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Mon, 12 May 2008 10:24:22 +0200
Message-ID: <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s26.bay0.hotmail.com ([65.54.246.226]:16931 "EHLO
	bay0-omc3-s26.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbYELI04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 04:26:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Mon, May 12, 2008 at 09:14:54AM +0200, Marco Berizzi wrote:
> >
> > PS: linux version shown by dmesg is 2.6.24 but it
> > is the results of 'git bisect good v2.6.24' and
> > 'git bisect bad v2.6.25'
>
> So what's the changeset hash for the source that produced this
> kernel?

root@Calimero:/tmp/GIT/herbert# git bisect good v2.6.24
You need to start by "git bisect start"
Do you want me to do it for you [Y/n]? Y
root@Calimero:/tmp/GIT/herbert# git bisect bad v2.6.25
Bisecting: 6353 revisions left to test after this
[dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf] Merge branch 'audit.b46' of
git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current

Then I have copied from 2.6.25 two files:

net/ipv4/xfrm4_tunnel.c and ipcomp.c because
of these bugs:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=11b47c8828d4cd1df21636719603784ec5e26067
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=363c11d7e1c2b2cc30e33416a518cea5ef9e0cc8
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=commit;h=cefe34bea77e194fd6b6a7a062e1620af2eef69f

and finally I have run 'make menuconfig' and
'make bzImage modules modules_install'



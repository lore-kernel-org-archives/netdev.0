From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: ping6 to own link-local address
Date: Tue, 20 Mar 2007 15:16:40 -0700
Message-ID: <1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com>
References: <20070320.101911.50437044.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, CHINEN@jp.ibm.com
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38601 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbXCTWQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 18:16:43 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2KMGfuR007204
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 18:16:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2KMGfXQ300414
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 18:16:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2KMGeHr011935
	for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 18:16:41 -0400
In-Reply-To: <20070320.101911.50437044.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-03-20 at 10:19 +0100, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> Hello.
>=20
> Recent 2.6.21-git kernels do not respond to ping6 queries
> to our own (local) link-local address.  Now bisecting...

The following patch seems to be the cause for this regression.

[IPV6] ROUTE: Do not route packets to link-local address on other devic=
e.

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Da0d78ebf3a0e33a1aeacf2fc518ad9273d6a1c2f

Thanks
Sridhar


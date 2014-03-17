From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V2 RE-SEND 1/7] net: sxgbe: add basic framework for Samsung
 10Gb ethernet driver
Date: Mon, 17 Mar 2014 10:38:58 -0700
Message-ID: <009c01cf4207$c8ada060$5a08e120$@samsung.com>
References: <007a01cf3e89$3bbdf460$b339dd20$%an@samsung.com>
 <20140314004454.GA10982@electric-eye.fr.zoreil.com>
 <000e01cf40ac$08c19290$1a44b7b0$@samsung.com>
 <20140316231101.GA23765@electric-eye.fr.zoreil.com>
 <005601cf4194$752c0c60$5f842520$@samsung.com>
 <20140317095853.27c27f6c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	ilho215.lee@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	'Joe Perches' <joe@perches.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:17441 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067AbaCQRjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 13:39:09 -0400
In-reply-to: <20140317095853.27c27f6c@nehalam.linuxnetplumber.net>
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Sun, 16 Mar 2014 20:53:25 -0700
> Byungho An <bh74.an@samsung.com> wrote:
> 
> > >
> > > They are used but they always point to the same set of methods.
> > > Those methods could thus be directly called.
> > Yes, those methods can be called directly.
> > But I think it is acceptable for manageability and extension for future.
> 
> That argument is only valid if:
>  1. you have hardware that will use it but it is not ready.
>  2. they will get used in next release (in < 6 mo)
I agree, it is expected that they will be used in 3 ~ 4 mo

> 
> Ths set of indirection has negative cost: it impedes readability, has to
be
> maintained, and hurts performance.
> 
> One of the principles of agile programming is NOT to build infrastructure
until
> it is needed. Otherwise you are likely to build it wrong.

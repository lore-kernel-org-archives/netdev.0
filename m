From: Phil Sutter <phil@nwl.cc>
Subject: Re: linear sk_buff
Date: Wed, 5 May 2010 21:32:36 +0200
Message-ID: <20100505193204.D847B4CD45@orbit.nwl.cc>
References: <o2kdac45061005051212na062f611m1c87240c367b5d38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:59409 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997Ab0EETlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 15:41:32 -0400
Received: from orbit.nwl.cc (localhost [127.0.0.1])
	by orbit.nwl.cc (Postfix) with ESMTP id 00DB24CD4A
	for <netdev@vger.kernel.org>; Wed,  5 May 2010 21:32:05 +0200 (CEST)
Received: from base (localhost [127.0.0.1])
	by orbit.nwl.cc (Postfix) with ESMTP id D847B4CD45
	for <netdev@vger.kernel.org>; Wed,  5 May 2010 21:32:04 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <o2kdac45061005051212na062f611m1c87240c367b5d38@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, May 05, 2010 at 10:12:06PM +0300, Mark Ryden wrote:
>  I would appreciate if someone in this mailing list  can say in a
> sentence or two what is a linear
> sk_buff and what is a non linear sk_buff; does it has to do with fragmentation?
> (I am sure that many know the answer, but I am confused and googling
> made me overconfused)

As far as I can tell, linear and non-linear sk_buffs differ in how the
data they contain is kept internally. Linear sk_buffs are trivial, it's
data resides in one, continuous block. In non-linear sk_buffs, data is
spread across multiple junks, organised in a data structure comparable
to e.g. scatterlists.

For further information, I'd highly recommend David Miller's "how SKBs
work": http://vger.kernel.org/~davem/skb.html .

Greetings, Phil

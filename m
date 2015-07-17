From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 2/3] rhashtable: Add a function for in order
 insertion and lookup in buckets
Date: Fri, 17 Jul 2015 14:11:57 +0200
Message-ID: <20150717121157.GE18033@pox.localdomain>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
 <1436917549-3666965-3-git-send-email-tom@herbertland.com>
 <20150715055411.GA31926@gondor.apana.org.au>
 <CALx6S34+f83R6R2uo2rcE27QMyRpgHtFD_NUD3+xocKVmSvMMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36959 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbGQML7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:11:59 -0400
Received: by wibud3 with SMTP id ud3so41071017wib.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 05:11:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S34+f83R6R2uo2rcE27QMyRpgHtFD_NUD3+xocKVmSvMMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/15 at 12:46pm, Tom Herbert wrote:
> On Tue, Jul 14, 2015 at 10:54 PM, Herbert Xu
> > The memory cost is merely 8 bytes per local port, is it really too
> > much?
> >
> Okay, it looks like there is already an additional hlist_node in
> skc_common that can be used for a secondary hash. It's conceivable
> this can be generalized and used in the TCP listeners also in
> combination with rhashtable.

Are you dropping this series entirely then?

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 13:35:17 -0700
Message-ID: <1363638917.21184.3.camel@edumazet-glaptop>
References: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
	 <CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
	 <1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20130318.131318.138158829629301794.davem@davemloft.net>
	 <CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
	 <CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eilong@broadcom.com,
	dmitry@broadcom.com, netdev@vger.kernel.org, yuvalmin@broadcom.com
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:43540 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755149Ab3CRUfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 16:35:20 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so1555045dad.32
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 13:35:19 -0700 (PDT)
In-Reply-To: <CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 13:06 -0700, Maciej =C5=BBenczykowski wrote:
> Current best guess is UPDATE_ESTAT_QSTAT_64 which uses SUB_64
> implemented via DIFF_64 which is crazy.

All these macros are really ugly, I wish someone could cleanup this
code.

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Thu, 22 Mar 2012 10:27:27 +0100
Message-ID: <20120322092727.GA21284@electric-eye.fr.zoreil.com>
References: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com> <20120228.212857.797446903975232476.davem@davemloft.net> <157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com> <20120228.223258.2261979237568571219.davem@davemloft.net> <CAB=NE6W-CYjEhbfYOv7XqXFGvdhZxRECqfAmgouaa5_j45gnOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, xiong@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com,
	Jesper Andersen <jespera@diku.dk>, Julia Lawall <julia@diku.dk>
To: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39410 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756598Ab2CVJaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2012 05:30:55 -0400
Content-Disposition: inline
In-Reply-To: <CAB=NE6W-CYjEhbfYOv7XqXFGvdhZxRECqfAmgouaa5_j45gnOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luis R. Rodriguez <rodrigue@qca.qualcomm.com> :
> On Tue, Feb 28, 2012 at 7:32 PM, David Miller <davem@davemloft.net> wrote:
[...]
> > To be honest tg3, as one example, supports quite a large array of
> > different pieces of hardware that use the same logical core.
> 
> At certain point it becomes a pain in the ass to support older
> chipsets, and simply easier to leave the older driver to rot.

I would avoid saying such things while trying to sell a plan for a bright
future of drivers maintained and supported by $BIGCORP. :o)

[...]
> Would it be worthwhile to consider alx upstream only for the newer
> chipsets (regardless of the litmus test, which I do agree with on
> technical grounds) in consideration for helping pave the way on
> killing proprietary drivers?

What is the situation regarding the availability for public use of
programming manuals and errata on older chipsets ?

I am fine with Qualcomm being completely uninterested in maintaining
code for old chipsets and dedicating manpower or $$$ on it, be it now,
tomorrow or after a new arrival of management execs. However it sends
a bad message if code for new chipsets comes in while users have to
maintain their pile of poo in the dark.

The hardware stays for years. It's one of the engineering problems of
the day. Killing proprietary drivers is an interesting goal but it is
far, far away.

Qualcomm should imvho meet davem's remarks with more short termed
deliverables.

-- 
Ueimor

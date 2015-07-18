From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvneta.c, MVNETA_TXQ_UPDATE_REG, shut down issue
Date: Sat, 18 Jul 2015 21:01:45 +0200
Message-ID: <20150718210145.29e76296@free-electrons.com>
References: <CAE7jHC8DxVckjEUTfO5CDA+EwBmQ5=0udVyEUqczp5_zT90Q8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rosenr@marvell.com, netdev@vger.kernel.org
To: Constantine Shulyupin <const@makelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:53966 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751591AbbGRTBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 15:01:48 -0400
In-Reply-To: <CAE7jHC8DxVckjEUTfO5CDA+EwBmQ5=0udVyEUqczp5_zT90Q8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Constantine,

On Sat, 18 Jul 2015 21:48:59 +0300, Constantine Shulyupin wrote:

> I try to run vanilla kernel 4.2.0 on custom Armada-370 board, based on
> DB-88F6710-BP.
> 
> The problem is that the board shuts down after writing to
> MVNETA_TXQ_UPDATE_REG in this code:

What do you mean by shut down? Physically turns off?

I hardly see how writing to this register can turn off the board. Can
you try on a non-custom A370 board?

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

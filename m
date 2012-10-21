From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 1/5] net/cadence: get rid of HAVE_NET_MACB
Date: Sun, 21 Oct 2012 22:26:34 +0200
Message-ID: <CAGhQ9VxxjU0qNTQtS=QHw-eHV10hMjE6DBZhFunr27yvdmX+rg@mail.gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-2-git-send-email-manabian@gmail.com>
	<20121021183005.GA18964@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:56917 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab2JUU0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 16:26:36 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1266602lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 13:26:34 -0700 (PDT)
In-Reply-To: <20121021183005.GA18964@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 8:30 PM, Jean-Christophe PLAGNIOL-VILLARD
<plagnioj@jcrosoft.com> wrote:
> On 16:23 Sun 21 Oct     , Joachim Eastwood wrote:
>> macb is a platform driver and there is nothing that prevents
>> this driver from being built on non-ARM/AVR32 platforms.
> if you want to drop the HAVE_NET_MACB you need to drop it everywher in one
> patch

Breaking it up in several patches doesn't seem to cause any build
failures and I did this in case the patches were going into different
git trees.

regards
Joachim Eastwood

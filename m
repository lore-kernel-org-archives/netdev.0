From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: Do a sanity check on the gpio number
Date: Mon, 18 Feb 2013 15:00:01 -0500 (EST)
Message-ID: <20130218.150001.165597927582810425.davem@davemloft.net>
References: <1361114964-10517-1-git-send-email-festevam@gmail.com>
	<20130218.144754.591538350954943449.davem@davemloft.net>
	<CAOMZO5DyfksHf9CK9MUGmdwNPmwc2EXtY+3krNffYdivvPr=0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001Ab3BRUAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 15:00:04 -0500
In-Reply-To: <CAOMZO5DyfksHf9CK9MUGmdwNPmwc2EXtY+3krNffYdivvPr=0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon, 18 Feb 2013 16:51:49 -0300

> On Mon, Feb 18, 2013 at 4:47 PM, David Miller <davem@davemloft.net> wrote:
>> From: Fabio Estevam <festevam@gmail.com>
>> Date: Sun, 17 Feb 2013 12:29:24 -0300
>>
>>> Since commit 372e722ea4d (gpiolib: use descriptors internally) the following
>>> warning is seen on a mx28evk board:
>>
>> [davem@drr linux]$ git describe 372e722ea4d
>> fatal: Not a valid object name 372e722ea4d
>> [davem@drr linux]$
>>
>> That commit ID doesn't exist in any tree I have access to.
> 
> It exists in linux-next.

linux-next commits are not valid to reference if they are not
either in the target tree where your patch belongs or Linus's
tree.

And if the change that causes the change to be needed doesn't even
exist in my tree or Linus's upstream, your "fix" has no business in my
tree either.

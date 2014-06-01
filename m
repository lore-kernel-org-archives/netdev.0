From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: use helper function to get rid of
 redundancy
Date: Sun, 1 Jun 2014 08:23:17 -0600
Message-ID: <20140601142317.GA19754@mail.gmail.com>
References: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
 <20140601072655.GA12277@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:49887 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbaFAOX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 10:23:26 -0400
Received: by mail-pa0-f49.google.com with SMTP id fa1so2253510pad.8
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 07:23:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140601072655.GA12277@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Sun, 01 Jun 2014 09:26:57 +0200

Hi Alex,

Thank you very much for the feedback.

> the at86rf230 driver supports several at86rf2xx chips. You split the
> at86rf212_set_channel which is at86rf212 specific in two function which
> are named at86rf230_foo.

I didn't "split" at86rf212_set_channel() in two functions. I spliced
those two sections of code and made at86rf212_set_channel() far
succinct and easy to read.

> Sorry, but I think we should not do this. One reason is that the code is
> much easier to read when we have one channel_set callback for at86rf23x
> and at86rf212 chips.

If you use one channel_set callback as before the change, how would you
overcome the redundancy?

> Btw. I preparing a big cleanup for this driver which supports regmap and
> asychronous handling for rx/tx paths.

Thank you for letting me know. I'm sure I will learn a lot.

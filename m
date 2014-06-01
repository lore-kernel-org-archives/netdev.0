From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: use helper function to get rid of
 redundancy
Date: Sun, 1 Jun 2014 09:26:57 +0200
Message-ID: <20140601072655.GA12277@omega>
References: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:50278 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaFAH1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 03:27:04 -0400
Received: by mail-we0-f177.google.com with SMTP id x48so3636018wes.8
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 00:27:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean,

the at86rf230 driver supports several at86rf2xx chips. You split the
at86rf212_set_channel which is at86rf212 specific in two function which
are named at86rf230_foo.

Sorry, but I think we should not do this. One reason is that the code is
much easier to read when we have one channel_set callback for at86rf23x
and at86rf212 chips.



Btw. I preparing a big cleanup for this driver which supports regmap and
asychronous handling for rx/tx paths.

- Alex

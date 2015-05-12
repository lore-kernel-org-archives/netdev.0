From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [patch -next] net: macb: OR vs AND typos
Date: Tue, 12 May 2015 23:58:17 +0530
Message-ID: <CAFcVECKzDsO9kFD8R0NvAb0aQErpopQ7jf0DP35x3iGpZedRdw@mail.gmail.com>
References: <20150512181524.GE5672@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Harini Katakam <harini.katakam@xilinx.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:33599 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932870AbbELS2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 14:28:19 -0400
In-Reply-To: <20150512181524.GE5672@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, May 12, 2015 at 11:45 PM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> The bitwise tests are always true here because it uses '|' where '&' is
> intended.

Yes. I'm sorry about that.
It slipped through my testing as well because I was using an SoC with
jumbo support.

Regards,
Harini

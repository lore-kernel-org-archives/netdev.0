From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 0/2] remove bridge BRIDGE_MODE_SWDEV
Date: Mon, 8 Dec 2014 12:04:25 +0100
Message-ID: <20141208110425.GB1885@nanopsycho.brq.redhat.com>
References: <1417972147-62196-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:44784 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614AbaLHLE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 06:04:28 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so4321496wiw.14
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 03:04:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417972147-62196-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please send the patches in reverse order. That would prevent compile
error during bisections. Thanks.


Sun, Dec 07, 2014 at 06:09:04PM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>
>Roopa Prabhu (2):
>  bridge: remove mode 'swdev'
>  rocker: remove swdev mode
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
> include/linux/rtnetlink.h            |    2 +-
> include/uapi/linux/if_bridge.h       |    1 -
> net/core/rtnetlink.c                 |   12 +++++++++---
> 4 files changed, 11 insertions(+), 22 deletions(-)
>
>-- 
>1.7.10.4
>

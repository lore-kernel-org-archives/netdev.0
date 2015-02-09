From: Bjorn Andersson <bjorn@kryo.se>
Subject: Re: [PATCH 1/2] net wireless wcn36xx add wcnss platform code
Date: Mon, 9 Feb 2015 10:00:11 -0800
Message-ID: <CAJAp7Oik5zavEKpWV4BikHu1a1QDibS0KqPr+492ZaRAHJ2Cbw@mail.gmail.com>
References: <20150118051222.32019.32719.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051644.32019.65489.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:39180 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933705AbbBISAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 13:00:14 -0500
Received: by mail-lb0-f173.google.com with SMTP id n10so4261712lbv.4
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 10:00:12 -0800 (PST)
In-Reply-To: <20150118051644.32019.65489.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2015 at 9:16 PM, Andy Green <andy.green@linaro.org> wrote:
> From: Eugene Krasnikov <k.eugene.e@gmail.com>
>
> AG modified to remove regulator handling not needed on msm8916-qrd
>
> Signed-off-by: Eugene Krasnikov <k.eugene.e@gmail.com>
> Signed-off-by: Andy Green <andy.green@linaro.org>
> ---
>  drivers/net/wireless/ath/wcn36xx/Makefile      |    2
>  drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c |  357 ++++++++++++++++++++++++

It seems like we're finally getting somewhere with the hwspinlock
devicetree binding, which will allow us to go ahead with the work on
getting smem, smd, smsm and smp2p into mainline.

With that in place we have fixed apis that this driver will run upon,
so I would like to suggest that we at that point fold this logic into
the driver itself rather than having this skim.

Regards,
Bjorn

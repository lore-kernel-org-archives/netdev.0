From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 1/2] net wireless wcn36xx add wcnss platform code
Date: Tue, 10 Feb 2015 08:41:03 +0200
Message-ID: <87iofanu9s.fsf@kamboji.qca.qualcomm.com>
References: <20150118051222.32019.32719.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051644.32019.65489.stgit@114-36-241-182.dynamic.hinet.net>
	<CAJAp7Oik5zavEKpWV4BikHu1a1QDibS0KqPr+492ZaRAHJ2Cbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Green <andy.green@linaro.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Bjorn Andersson <bjorn@kryo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53107 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbbBJGsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 01:48:36 -0500
In-Reply-To: <CAJAp7Oik5zavEKpWV4BikHu1a1QDibS0KqPr+492ZaRAHJ2Cbw@mail.gmail.com>
	(Bjorn Andersson's message of "Mon, 9 Feb 2015 10:00:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjorn Andersson <bjorn@kryo.se> writes:

> On Sat, Jan 17, 2015 at 9:16 PM, Andy Green <andy.green@linaro.org> wrote:
>> From: Eugene Krasnikov <k.eugene.e@gmail.com>
>>
>> AG modified to remove regulator handling not needed on msm8916-qrd
>>
>> Signed-off-by: Eugene Krasnikov <k.eugene.e@gmail.com>
>> Signed-off-by: Andy Green <andy.green@linaro.org>
>> ---
>>  drivers/net/wireless/ath/wcn36xx/Makefile      |    2
>>  drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c |  357 ++++++++++++++++++++++++
>
> It seems like we're finally getting somewhere with the hwspinlock
> devicetree binding, which will allow us to go ahead with the work on
> getting smem, smd, smsm and smp2p into mainline.
>
> With that in place we have fixed apis that this driver will run upon,
> so I would like to suggest that we at that point fold this logic into
> the driver itself rather than having this skim.

Yeah, this approach would be much better.

-- 
Kalle Valo

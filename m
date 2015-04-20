From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [RFC][PATCH] net: stmmac: use msleep instead of udelay for gpio
 reset
Date: Mon, 20 Apr 2015 15:11:31 +0200
Message-ID: <5534FB03.6020302@st.com>
References: <1429369359-8204-1-git-send-email-michael@amarulasolutions.com>	<CAOMZO5DVU=w+tzgZhTY2z=QNQ4kQbXKOmiSLpK-vvL_kCo_mHA@mail.gmail.com> <CAOf5uw=0dw-4kHTCgiN143f33YxpZLsqsHyTcDfxnKCW5aDpzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Michael Trimarchi <michael@amarulasolutions.com>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:42919 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbbDTNLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 09:11:40 -0400
In-Reply-To: <CAOf5uw=0dw-4kHTCgiN143f33YxpZLsqsHyTcDfxnKCW5aDpzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/2015 6:11 AM, Michael Trimarchi wrote:
> Hi
>
> On Apr 19, 2015 1:37 AM, "Fabio Estevam" <festevam@gmail.com
> <mailto:festevam@gmail.com>> wrote:
>  >
>  > On Sat, Apr 18, 2015 at 12:02 PM, Michael Trimarchi
>  > <michael@amarulasolutions.com <mailto:michael@amarulasolutions.com>>
> wrote:
>  >
>  > >                 reset_gpio = data->reset_gpio;
>  > > -               active_low = data->active_low;
>  > > +               active_low = !!data->active_low;
>  >
>  > This is an unrelated change.
>
> I have already try to minimize the change. Anyway I will repost it if
> necessary

yes send V2 w/ related changes for ms reset time only

thanks

Peppe

> Michael
>

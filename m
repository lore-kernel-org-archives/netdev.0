From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [RFC][PATCH] net: stmmac: use msleep instead of udelay for gpio reset
Date: Sat, 18 Apr 2015 14:37:57 -0300
Message-ID: <CAOMZO5DVU=w+tzgZhTY2z=QNQ4kQbXKOmiSLpK-vvL_kCo_mHA@mail.gmail.com>
References: <1429369359-8204-1-git-send-email-michael@amarulasolutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Trimarchi <michael@amarulasolutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:33685 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112AbbDRRh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2015 13:37:59 -0400
Received: by layy10 with SMTP id y10so100716488lay.0
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2015 10:37:58 -0700 (PDT)
In-Reply-To: <1429369359-8204-1-git-send-email-michael@amarulasolutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 18, 2015 at 12:02 PM, Michael Trimarchi
<michael@amarulasolutions.com> wrote:

>                 reset_gpio = data->reset_gpio;
> -               active_low = data->active_low;
> +               active_low = !!data->active_low;

This is an unrelated change.

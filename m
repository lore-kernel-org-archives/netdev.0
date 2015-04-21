From: Michael Trimarchi <michael@amarulasolutions.com>
Subject: Re: [PATCH V2] net: stmmac: use msleep instead of udelay for gpio
 reset
Date: Wed, 22 Apr 2015 01:13:47 +0200
Message-ID: <20150421231347.GA3392@panicking>
References: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
 <20150421.173540.1253961571051792975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, festevam@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34596 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965016AbbDUXOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 19:14:03 -0400
Received: by pdbqa5 with SMTP id qa5so255544295pdb.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 16:14:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150421.173540.1253961571051792975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tue, Apr 21, 2015 at 05:35:40PM -0400, David Miller wrote:
> From: Michael Trimarchi <michael@amarulasolutions.com>
> Date: Tue, 21 Apr 2015 13:16:13 +0200
> 
> > -			udelay(data->delays[0]);
>  ...
> > +			msleep(max(1U, data->delays[0] / 1000));
> 
> That looks very ugly with that max() expression in there.
>

Is fine for you a DIV_ROUND_UP?

> Please find some clean way to get rid of it if you want to
> make this conversion.
>

Agree, I will repost it

Michael

> Thanks.

-- 
| Michael Nazzareno Trimarchi                     Amarula Solutions BV |
| COO  -  Founder                                      Cruquiuskade 47 |
| +31(0)851119172                                 Amsterdam 1018 AM NL |
|                  [`as] http://www.amarulasolutions.com               |

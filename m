From: kc <nirvana.code@gmail.com>
Subject: Re: UDP Out 0f Sequence
Date: Wed, 20 Sep 2006 19:13:15 +0530
Message-ID: <e92e3a770609200643m55603f50u10a597a6dc5001aa@mail.gmail.com>
References: <F444CAE5E62A714C9F45AA292785BED30EB97591@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:23394 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751155AbWITNnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 09:43:18 -0400
Received: by wr-out-0506.google.com with SMTP id i3so78980wra
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2006 06:43:17 -0700 (PDT)
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB97591@esng11p33001.sg.csfb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

network transit. different datagrams might go through different
routes, hence the out-of-sequence arrival.

On 9/20/06, Majumder, Rajib <rajib.majumder@credit-suisse.com> wrote:
> Hi,
>
> If I write UDP datagrams 1,2 and 3 to network and if the receiver receives in order 2,1, and 3, where can the sequence get changed? Is it at the source stack, network transit or destination stack?
>
> Any reply is highly appreciated.
>
> Thanks
>
> Rajib
>
> ==============================================================================
> Please access the attached hyperlink for an important electronic communications disclaimer:
>
> http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
> ==============================================================================
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

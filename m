From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sat, 17 Aug 2013 22:04:26 +0300
Message-ID: <CAM8tLiNTZogOa7Cg_A8brjGn06xhSUHFZ=YoBSLCFHDiKVT8NA@mail.gmail.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	<1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	<1363651672.21184.17.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	<CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	<CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
	<1376766116.21329.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jerry Chu <hkchu@google.com>, Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:57475 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab3HQTE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:04:26 -0400
Received: by mail-ve0-f177.google.com with SMTP id cz11so2097603veb.36
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 12:04:26 -0700 (PDT)
In-Reply-To: <1376766116.21329.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 17, 2013 at 10:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2013-08-17 at 21:52 +0300, Dmitry Kravkov wrote:
>
>>
>> Current bnx2x HW is not able to perform CSUM validation for
>> encapsulated packets, so in any case host needs to do that.
>> Today GRO/TPA feature depends on CSUM, but theoretically (i did not
>> investigate it) and probably HW can provide aggregated packets w/o
>> csum validation - this will save headers processing for host.
>
> I am not sure I understand this.
>
> Aggregation cannot be done if csums are not validated.
>
>

Thanks. Eric. So we can't do with current bnx2x HW.

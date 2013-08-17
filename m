From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sat, 17 Aug 2013 12:01:56 -0700
Message-ID: <1376766116.21329.9.camel@edumazet-glaptop>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	 <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	 <1363651672.21184.17.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	 <CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	 <CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:45953 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab3HQTB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:01:57 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so3445520pdj.36
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 12:01:57 -0700 (PDT)
In-Reply-To: <CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-17 at 21:52 +0300, Dmitry Kravkov wrote:

> 
> Current bnx2x HW is not able to perform CSUM validation for
> encapsulated packets, so in any case host needs to do that.
> Today GRO/TPA feature depends on CSUM, but theoretically (i did not
> investigate it) and probably HW can provide aggregated packets w/o
> csum validation - this will save headers processing for host.

I am not sure I understand this.

Aggregation cannot be done if csums are not validated.

From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sun, 3 May 2015 12:01:09 -0700
Message-ID: <20150503190108.GF2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
 <20150502232040.GB2731450@devbig242.prn2.facebook.com>
 <m2bni2tsv0.wl@sfc.wide.ad.jp>
 <20150503033801.GE2731450@devbig242.prn2.facebook.com>
 <m27fspu42k.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41714 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751549AbbECTCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 15:02:09 -0400
Content-Disposition: inline
In-Reply-To: <m27fspu42k.wl@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hajime,

On Sun, May 03, 2015 at 11:29:55PM +0900, Hajime Tazaki wrote:
> the test uses two nodes (running on ns-3 network simulator
> with net-next kernel), which is connected via a
> point-to-point data link: payload is encapsulated by PPP
> (RFC1661).
> 
> so there is no need of neighbor resolution (ARP, NS/NA) on
> that link (dev->flags has IFF_NOARP and IFF_POINTOPOINT bits).
> 
>              point-to-point
>    node 0  <---------------> node 1
> 2001:1::1/64               2001:1::2/64
> 
> let me know if you need further information.
Thanks for the details and confirming the last patch.  I think I may
know what could be wrong.  I am going to confirm it first by trying
to reproduce it.

> I'm going to create a real environment to figure out a
> minimum-reproducible command set that we can try.
That will be great!

> do you have any chance to create an interface with IFF_NOARP
> and IFF_POINTOPOINT (some tunnel device ?) on the latest
> net-next kernel ?
I am going to give it a try.

Thanks,
--Martin

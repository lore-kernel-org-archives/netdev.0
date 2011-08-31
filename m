From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 19:16:41 +0300
Message-ID: <201108311916.41564.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <20110831173749.60649b50@alice> <20110831175120.739bd5c2@alice>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2044 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756683Ab1HaQRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 12:17:16 -0400
In-Reply-To: <20110831175120.739bd5c2@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 31 August 2011 18:51:20 Michal Schmidt wrote:
> On Wed, 31 Aug 2011 17:37:49 +0200 Michal Schmidt wrote:
> > I could restore dev->features before
> > returning if bnx2x_reload_if_running() fails.
> 
> Or even safer - restore them always:
> 	...
> 	u32 orig_features = dev->features;
> 	dev->features = features;
>         ret = bnx2x_reload_if_running(dev);
>         dev->features = orig_features;
>         return ret;
> 	...
> This way we don't have to assume anything about
> __netdev_update_features().

I agree - it's the best choice if we go for a bnx2x-only solution.

thanks,
vlad

> 
> Michal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

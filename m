From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: downgrade Max BW error message to debug
Date: Thu, 18 Aug 2011 15:22:00 +0300
Message-ID: <1313670121.5576.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
 <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E490A1E.3060209@redhat.com>
 <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E493798.7010405@redhat.com>
 <1313434042.30399.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E4A56C0.4030009@redhat.com>
 <1313498708.24298.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20110817175037.2777724a@brian.englab.brq.redhat.com>
 <1313603055.12483.3.camel@lb-tlvb-eilong.il.broadcom.com>
 <20110818133751.3ba77279@brian.englab.brq.redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1645 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755786Ab1HRMWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 08:22:19 -0400
In-Reply-To: <20110818133751.3ba77279@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-08-18 at 04:37 -0700, Michal Schmidt wrote:
> On Wed, 17 Aug 2011 20:44:15 +0300 Eilon Greenstein wrote:
> > I think that we should use DP instead of DBG_ERR. How about this one:
> ... 
> > Can you sing-off on somethign like this?
> 
> OK, let's use DP. Thanks!
> 
> 
> Subject: [PATCH v2] bnx2x: downgrade Max BW error message to debug
> 
> There are valid configurations where Max BW is configured to zero for
> some VNs.
> Print the message only if debugging is enabled and do not call the
> configuration "illegal".
> 
> [v2: use DP(), not BNX2X_DBG_ERR(); recommended by Eilon Greenstein.]
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Michal!



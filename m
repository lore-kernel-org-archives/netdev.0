From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH net-next 0/7] bnx2x: move bnx2x to separate folder
 and divide to files
Date: Tue, 27 Jul 2010 23:09:35 +0300
Message-ID: <1280261375.8566.32.camel@lb-tlvb-dmitry>
References: <1280257298.8566.8.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2771 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab0G0ULX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 16:11:23 -0400
In-Reply-To: <1280257298.8566.8.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PATCH 8/7 will include MAINTAINERS update for new location

On Tue, 2010-07-27 at 12:01 -0700, Dmitry Kravkov wrote:
> Hi,
> Please consider applying following patch series to the net-next.
> The series creates separate folder for bxn2x files and divides
> bnx2x_main file into several logical parts:
> 	bnx2x_cmn.[ch] - common functionality for PF and upcommimg 
> 			 VF drivers
> 	bnx2x_stat.[ch] - statistics handling
> 	ethtool.c - ethtool related function and structs
> 
> After applying this series, integration of latest bnx2x patches
> from net-2.6 which include fixes for statistics handling can't
> be performed in a "automatic" way then i can suggest to re-submitting
> these two patches.
> 
> Dmitry
> ---
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 




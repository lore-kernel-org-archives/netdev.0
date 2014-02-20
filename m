From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Thu, 20 Feb 2014 10:07:21 -0800
Message-ID: <53064459.3030106@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com> <1392726375-32001-2-git-send-email-hariprasad@chelsio.com> <53051E48.9050901@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, dm@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:36071
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754520AbaBTSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:44:24 -0500
In-Reply-To: <53051E48.9050901@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/19/14 13:12, Steve Wise wrote:
>
> You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as 
> part of this series.

   I'm ~pretty sure~ that the "word on the street" was that the 
community wanted to get away from the SPEED_XXX symbols since they 
simply represented the values XXX.  Thus they didn't offer any real 
symbolic isolation from weird constants, etc.  I believe that the old 
SPEED_XXX values were left in place in order to avoid making tons of 
changes everywhere ...

Casey

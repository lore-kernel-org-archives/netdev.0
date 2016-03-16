From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/6] bridge: simplify the stp_state_store by
 calling store_bridge_parm
Date: Wed, 16 Mar 2016 15:06:23 +0100
Message-ID: <56E9685F.7030102@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
 <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37095 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008AbcCPOG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:06:26 -0400
Received: by mail-wm0-f44.google.com with SMTP id p65so74227090wmp.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:06:25 -0700 (PDT)
In-Reply-To: <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 02:34 PM, Xin Long wrote:
> There are some repetitive codes in stp_state_store, we can remove
> them by calling store_bridge_parm.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_sysfs_br.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
> 

LGTM. Note: it introduces a bug (missing rtnl) until patch 04 is applied.

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

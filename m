From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/6] bridge: simplify the forward_delay_store by
 calling store_bridge_parm
Date: Wed, 16 Mar 2016 14:58:56 +0100
Message-ID: <56E966A0.4050704@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34695 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966719AbcCPN7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:59:03 -0400
Received: by mail-wm0-f47.google.com with SMTP id p65so191377637wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:58:58 -0700 (PDT)
In-Reply-To: <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 02:34 PM, Xin Long wrote:
> There are some repetitive codes in forward_delay_store, we can remove
> them by calling store_bridge_parm.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_sysfs_br.c | 27 ++++++++++-----------------
>  1 file changed, 10 insertions(+), 17 deletions(-)
> 

I actually have a similar patch in my tree. :-)

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

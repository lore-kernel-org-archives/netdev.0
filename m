From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/6] netns: always provide the id to
 rtnl_net_fill()
Date: Wed, 6 May 2015 13:25:52 +0200
Message-ID: <20150506112552.GB25248@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34489 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbEFLZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 07:25:55 -0400
Received: by wicmx19 with SMTP id mx19so122745649wic.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 04:25:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430906288-5108-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> The goal of this commit is to prepare the rework of the locking of nsnid
> protection.
> After this patch, rtnl_net_notifyid() will not call anymore __peernet2id(),
> ie no idr_* operation into this function.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>

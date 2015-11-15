From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: translate host order to network order when
 setting a hmacid
Date: Sun, 15 Nov 2015 18:28:32 -0500 (EST)
Message-ID: <20151115.182832.1464025397909135510.davem@davemloft.net>
References: <8cede44279b2f01a58fa02d4bb46b40fb630563f.1447304827.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbKOX2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 18:28:34 -0500
In-Reply-To: <8cede44279b2f01a58fa02d4bb46b40fb630563f.1447304827.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 12 Nov 2015 13:07:07 +0800

> now sctp auth cannot work well when setting a hmacid manually, which
> is caused by that we didn't use the network order for hmacid, so fix
> it by adding the transformation in sctp_auth_ep_set_hmacs.
> 
> even we set hmacid with the network order in userspace, it still
> can't work, because of this condition in sctp_auth_ep_set_hmacs():
> 
> 		if (id > SCTP_AUTH_HMAC_ID_MAX)
> 			return -EOPNOTSUPP;
> 
> so this wasn't working before and thus it won't break compatibility.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable, thanks.

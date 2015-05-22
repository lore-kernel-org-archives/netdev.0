From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 04/11] net: Get skb hash over flow_keys
 structure
Date: Fri, 22 May 2015 08:52:40 +0200
Message-ID: <20150522065240.GD2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34515 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbEVGwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 02:52:49 -0400
Received: by wicmc15 with SMTP id mc15so31948395wic.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 23:52:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:39AM CEST, tom@herbertland.com wrote:
>This patch changes flow hashing to use jhash2 over the flow_keys
>structure instead just doing jhash_3words over src, dst, and ports.
>This method will allow us take more input into the hashing function
>so that we can include full IPv6 addresses, VLAN, flow labels etc.
>without needing to resort to xor'ing which makes for a poor hash.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

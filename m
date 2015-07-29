From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 11:13:33 +0200
Message-ID: <20150729091333.GB13113@pox.localdomain>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34623 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbG2JNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:13:37 -0400
Received: by wibud3 with SMTP id ud3so211964699wib.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:13:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438124526-2129341-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/15 at 04:02pm, Tom Herbert wrote:
> This patch creates sk_set_txhash and eliminates protocol specific
> inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
> random number instead of performing flow dissection. sk_set_txash
> is also allowed to be called multiple times for the same socket,
> we'll need this when redoing the hash for negative routing advice.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Doesn't this break TX hashing with SO_REUSEPORT?

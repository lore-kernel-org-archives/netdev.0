From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: use right in and out stream cnt
Date: Sat, 01 Apr 2017 20:12:45 -0700 (PDT)
Message-ID: <20170401.201245.1804602376522322384.davem@davemloft.net>
References: <046f41fee71d352458eccf900bcef54e24cb8aa8.1490954248.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdDBDMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 23:12:47 -0400
In-Reply-To: <046f41fee71d352458eccf900bcef54e24cb8aa8.1490954248.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 31 Mar 2017 17:57:28 +0800

> Since sctp reconf was added in sctp, the real cnt of in/out stream
> have not been c.sinit_max_instreams and c.sinit_num_ostreams any
> more.
> 
> This patch is to replace them with stream->in/outcnt.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.

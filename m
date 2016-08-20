From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: linearize early if it's not GSO
Date: Fri, 19 Aug 2016 17:10:16 -0700 (PDT)
Message-ID: <20160819.171016.2080741015571973906.davem@davemloft.net>
References: <c333cd2ab2c828577251c6f75a3cc5e5f3683eb8.1471542789.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        daniel@iogearbox.net, nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56011 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932471AbcHTATb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:19:31 -0400
In-Reply-To: <c333cd2ab2c828577251c6f75a3cc5e5f3683eb8.1471542789.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 18 Aug 2016 14:58:35 -0300

> Because otherwise when crc computation is still needed it's way more
> expensive than on a linear buffer to the point that it affects
> performance.
> 
> It's so expensive that netperf test gives a perf output as below:
 ...
> Fixes: 3acb50c18d8d ("sctp: delay as much as possible skb_linearize")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Consider fragmentation of udp tunneled skbs
 in 'ip_finish_output_gso'
Date: Tue, 19 Jul 2016 16:40:34 -0700 (PDT)
Message-ID: <20160719.164034.1813590621318818547.davem@davemloft.net>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@ravellosystems.com,
	edumazet@google.com, hannes@stressinduktion.org, fw@strlen.de
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbcGSXkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 19:40:36 -0400
In-Reply-To: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Mon, 18 Jul 2016 14:49:32 +0300

> Currently IP fragmentation of GSO segments that exceed dst mtu is
> considered only in the ipv4 forwarding case.
> 
> There are cases where GSO skbs that are bridged and then udp-tunneled
> may have gso_size exceeding the egress device mtu.
> It makes sense to fragment them, as in the non GSOed code path.
> 
> The exact cases where this behavior is needed is described and addressed
> in the 2nd patch.

Series applied, thanks.

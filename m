From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] netfilter/libxt_hashlimit: new feature/algorithm for
 xt_hashlimit
Date: Fri, 8 Sep 2017 15:10:59 +0200
Message-ID: <20170908131059.GA30127@salvia>
References: <1503089946-15996-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
        johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:35159 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755392AbdIHNLZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 09:11:25 -0400
Content-Disposition: inline
In-Reply-To: <1503089946-15996-1-git-send-email-vpai@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 04:59:06PM -0400, Vishwanath Pai wrote:
> This patch adds a new feature to hashlimit that allows matching on the
> current packet/byte rate without rate limiting. This can be enabled
> with a new flag --hashlimit-rate-match. The match returns true if the
> current rate of packets is above/below the user specified value.

Applied to iptables:

http://git.netfilter.org/iptables/commit/?id=1c32e5606fdf53856cba0cd9bc7b3f8b584b2cc2

Thanks.

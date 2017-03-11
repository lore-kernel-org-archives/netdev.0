From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Sat, 11 Mar 2017 22:51:47 +0100
Message-ID: <20170311215147.lfyqz4jjtxyo5gm4@nataraja>
References: <20170309164302.13550-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:44084 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932619AbdCKVwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:52:14 -0500
Content-Disposition: inline
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

> Andreas Schultz (7):
>   gtp: switch from struct socket to struct sock for the GTP sockets
>   gtp: make GTP sockets in gtp_newlink optional
>   gtp: merge gtp_get_net and gtp_genl_find_dev
>   gtp: consolidate gtp socket rx path
>   gtp: unify genl_find_pdp and prepare for per socket lookup
>   gtp: consolidate pdp context destruction into helper
>   gtp: add socket to pdp context


I agree with the conceptual and architectural direction that you're
taking the code, and I also think your current patchset is good to go
ahead, so feel free to add my "Acked-By: Harald Welte <laforge@gnumonks.org>".

However, the usual disclaimer: I've been out of kernel networking land
for a long time, so my review skills are clearly not the best anymore.
I'm happy for any input others can give from that point of view.

There are some minor typos in the commit logs, but at the rate my typos
increase over the years, I am the last one to complain about wasting
time on fixing these ;)

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

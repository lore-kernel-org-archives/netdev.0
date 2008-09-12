From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [stable] regression in iptables: recent filter
Date: Thu, 11 Sep 2008 20:01:33 -0700
Message-ID: <20080911200133.48be32fa.akpm@linux-foundation.org>
References: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Coady <grant_lkml@dodo.com.au>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Grant Coady <gcoady.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60710 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754849AbYILDCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:02:09 -0400
In-Reply-To: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2008 11:53:35 +1000 Grant Coady <grant_lkml@dodo.com.au> wrote:

> Hi there,
> 
> Last known good kernel: 2.6.24.7
> 
> # iptables -N calmrate
> # iptables -A calmrate -p tcp -m state --state NEW \
> 	-m recent --name listrate --update --rttl \
> 	--seconds 60 --hitcount 60 -j DROP
> iptables: Unknown error 4294967295
> 
> Fails for 2.6.25.17 and 2.6.26.5
> 
> dmesg + config: http://bugsplatter.id.au/kernel/boxen/deltree/
> 

(cc netdev)

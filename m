From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] bridge: netfilter: checkpatch null comparison fixes
Date: Tue, 7 Jun 2016 17:21:38 +0200
Message-ID: <20160607152138.GB23655@salvia>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
 <1462843618-21914-4-git-send-email-me@tobin.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: tcharding <me@tobin.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58196 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161418AbcFGPVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 11:21:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1CEE1921774
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:21:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0F13B15D62E
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:21:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E6D1215D633
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:21:39 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1462843618-21914-4-git-send-email-me@tobin.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 11:26:58AM +1000, tcharding wrote:
> From: Tobin C Harding <me@tobin.cc>
> 
> checkpatch produces comparison to null 'checks'.
> 
> This patch amends them.

We have quite a lot of these in the netfilter tree, so I'd rather
start using prefered coding style from now on rather than getting a
large patch to convert this. This just makes harder to pass back
patches to -stable branches as the process becomes not so immediate.

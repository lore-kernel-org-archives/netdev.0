From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 6/7] rhashtable: initialize atomic nelems
 variable
Date: Wed, 7 Jan 2015 09:53:32 +0000
Message-ID: <20150107095332.GK21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
 <1420609318-3261-7-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32809 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbbAGJxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:53:33 -0500
Content-Disposition: inline
In-Reply-To: <1420609318-3261-7-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 01:41pm, Ying Xue wrote:
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Is this really needed at all? We initialize the full rhashtable
struct to 0 in rhashtable_init().

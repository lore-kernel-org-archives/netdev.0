From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3 v2] net: Allow user to get table id from
 route lookup
Date: Tue, 15 Sep 2015 12:02:07 -0700 (PDT)
Message-ID: <20150915.120207.715276225859908652.davem@davemloft.net>
References: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
	<1441227516-39692-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbIOTCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 15:02:08 -0400
In-Reply-To: <1441227516-39692-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  2 Sep 2015 13:58:36 -0700

> rt_fill_info which is called for 'route get' requests hardcodes the
> table id as RT_TABLE_MAIN which is not correct when multiple tables
> are used. Use the newly added table id in the rtable to send back
> the correct table similar to what is done for IPv6.
> 
> To maintain current ABI a new request flag, RTM_F_LOOKUP_TABLE, is
> added to indicate the actual table is wanted versus the hardcoded
> response.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - use a new request flag to indicate the real table id is wanted
>   (suggested by Thomas)

Applied.

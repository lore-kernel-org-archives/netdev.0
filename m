From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 0/3] Refactor vxlan and l2tp to use common UDP
 tunnel APIs
Date: Fri, 05 Sep 2014 17:19:42 -0700 (PDT)
Message-ID: <20140905.171942.713956165843587914.davem@davemloft.net>
References: <1409817462-7957-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaIFATn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:19:43 -0400
In-Reply-To: <1409817462-7957-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Thu,  4 Sep 2014 00:57:39 -0700

> Andy Zhou (3):
>   udp-tunnel: Expand UDP tunnel APIs
>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>     functions.
>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel 
>        functions

Way too many ifdefs in *.c code, and your indentation is not correct.
For function calls that span multiple lines, you must start the second
and subsequent lines exactly at the first column after the openning
parenthesis of the first line.  You must use the appropriate number of
TAB and SPACE characters necessary to do so.  If you are indenting these
lines only using TAB characters, you are very likely doing it wrong.

Thanks.

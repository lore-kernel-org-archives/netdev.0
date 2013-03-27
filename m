From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp_pch: eliminate a number of sparse warnings
Date: Wed, 27 Mar 2013 00:51:38 -0400 (EDT)
Message-ID: <20130327.005138.1102221495315013055.davem@davemloft.net>
References: <1364359512-29228-1-git-send-email-kpark3469@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, keun-o.park@windriver.com,
	netdev@vger.kernel.org
To: kpark3469@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab3C0Evm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 00:51:42 -0400
In-Reply-To: <1364359512-29228-1-git-send-email-kpark3469@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kpark3469@gmail.com
Date: Wed, 27 Mar 2013 13:45:12 +0900

> -module_param_string(station, pch_param.station, sizeof pch_param.station, 0444);
> +module_param_string(station,
> +	 pch_param.station, sizeof(pch_param.station), 0444);

Function arguments on the second and subsequent line of a function
call should line up with the first column after the colum of the
openning parenthesis of the first line.

Don't just use TAB characters exclusively, the above looks
incredibly ugly.  Instead use the necessary combination of
TAB and space characters necessary to make the argument
line up at the correct column so it all lines up and looks
nice.

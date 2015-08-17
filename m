From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Move VRF change to udp_sendmsg to inlined function
Date: Mon, 17 Aug 2015 15:39:00 -0700 (PDT)
Message-ID: <20150817.153900.1442076757786419108.davem@davemloft.net>
References: <1439683919-3066-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbbHQWjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:39:01 -0400
In-Reply-To: <1439683919-3066-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 15 Aug 2015 18:11:59 -0600

> Functionally equivalent, but as an inlined function with VRF config
> check it completely compiles out if VRF is not enabled.
> 
> Suggested-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Please do not use the 'inline' keyword for functions in foo.c files,
let the compiler decide.

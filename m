From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 Add more initializations of the new
 nl_info.nl_net field
Date: Sat, 23 Feb 2008 20:02:57 -0800 (PST)
Message-ID: <20080223.200257.24167841.davem@davemloft.net>
References: <20080221165149.928863399@theryb.frec.bull.fr>
	<20080221165219.657302066@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753213AbYBXECQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 23:02:16 -0500
In-Reply-To: <20080221165219.657302066@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: benjamin.thery@bull.net
Date: Thu, 21 Feb 2008 17:51:50 +0100

> Add more missing initializations of the new nl_info.nl_net field in 
> IPv6 stack. 
> This field will be used when network namespaces are fully supported.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Initializations to "zero" are not necessary nor usually
done in these kinds of cases.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Clean the ip_sockglue.c from some ugly ifdefs
Date: Mon, 05 Nov 2007 21:32:41 -0800 (PST)
Message-ID: <20071105.213241.124872189.davem@davemloft.net>
References: <4729F642.7000709@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751327AbXKFFcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 00:32:42 -0500
In-Reply-To: <4729F642.7000709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 01 Nov 2007 18:52:34 +0300

> The #idfed CONFIG_IP_MROUTE is sometimes places inside the if-s,
> which looks completely bad. Similar ifdefs inside the functions
> looks a bit better, but they are also not recommended to be used.
> 
> Provide an ifdef-ed ip_mroute_opt() helper to cleanup the code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.

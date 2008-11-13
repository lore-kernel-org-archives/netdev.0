From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
 structures are passed and all rx queues are checked
Date: Wed, 12 Nov 2008 16:23:59 -0800 (PST)
Message-ID: <20081112.162359.114568315.davem@davemloft.net>
References: <20081111173708.GC30481@hmsreliant.think-freely.org>
	<1226426364.23218.14.camel@HP1>
	<20081111185559.GD30481@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45631
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750927AbYKMAX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 19:23:59 -0500
In-Reply-To: <20081111185559.GD30481@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 11 Nov 2008 15:58:03 -0500

> Fix bnx2 so that netpoll works properly.  Specifically:
> 
> 1) Fix parameters to bnx2_interrupt to be a struct bnx2_napi rather than a
> struct net_device
> 
> 2) Fix poll_controller method to check every queue in the rx case so frames
> aren't missed
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This looks good, applied, thanks Neil!

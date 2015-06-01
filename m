From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Mon, 01 Jun 2015 16:05:56 -0700 (PDT)
Message-ID: <20150601.160556.2300618386117820098.davem@davemloft.net>
References: <1433132704-21927-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbFAXF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 19:05:57 -0400
In-Reply-To: <1433132704-21927-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon,  1 Jun 2015 13:25:04 +0900

> The rocker (switch) of a rocker_port may be trivially obtained from
> the latter it seems cleaner not to pass the former to a function when
> the latter is being passed anyway.
> 
> rocker_port_rx_proc() is omitted from this change as it is a hot path case.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Acked-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks Simon.

Andy, DO NOT quote an entire patch just to ACK it.

That is, unless you think my time is better spend scrolling over and
over across multiple copies of the same patch in the patchwork page
while I review a change than it is spent actually reviewing people's
work.

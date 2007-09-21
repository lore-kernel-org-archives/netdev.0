From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: Fri, 21 Sep 2007 14:49:05 +0200
Message-ID: <46F3BDC1.2020200@trash.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de> <20070920184533.3795.3@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63749 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbXIUM4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:56:54 -0400
In-Reply-To: <20070920184533.3795.3@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> +config CAN_RAW_USER
> +	bool "Allow non-root users to access Raw CAN Protocol sockets"


If you plan to remove this option, it should happen before merging
since it affects userspace visible behaviour.


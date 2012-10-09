From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Remove code that stops further access to BE
 NIC based on UE bits
Date: Tue, 09 Oct 2012 13:55:56 -0400 (EDT)
Message-ID: <20121009.135556.1173953819006480045.davem@davemloft.net>
References: <20121009041821.GA16595@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab2JIRz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 13:55:58 -0400
In-Reply-To: <20121009041821.GA16595@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Mon, 8 Oct 2012 23:18:21 -0500

> On certain platforms, BE hardware could  falsely indicate UE.
> For BE family of NICs, do not set hw_error based on the UE bits.
> If there was a real fatal error, the corresponding h/w block will
> automatically go offline and stop traffic.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied.

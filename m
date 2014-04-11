From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Thu, 10 Apr 2014 20:51:28 -0400 (EDT)
Message-ID: <20140410.205128.1312451576920196881.davem@davemloft.net>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	w@1wt.eu, tawfik@marvell.com, alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaDKAva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 20:51:30 -0400
In-Reply-To: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is not really driver specific code.

Please create an appropriate abstraction, and put this code in a
common place so that any driver can do this.

Thanks.

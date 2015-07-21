From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] sctp: fix src address selection if using
 secondary address
Date: Tue, 21 Jul 2015 00:20:45 -0700 (PDT)
Message-ID: <20150721.002045.1819611920291195410.davem@davemloft.net>
References: <cover.1437145508.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbGUHUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:20:47 -0400
In-Reply-To: <cover.1437145508.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 17 Jul 2015 12:34:16 -0300

> This series improves the way SCTP chooses its src address so that the
> choosen one will always belong to the interface being used for output.
> 
> v1->v2:
>  - split out the refactoring from the fix itself
>  - Doing a full reverse routing as in v1 is not necessary. Only looking
>    for the interface that has the address and comparing its number is
>    enough.

Series applied, thanks.

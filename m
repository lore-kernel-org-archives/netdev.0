From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: change type of alive from int to bool
Date: Mon, 12 Oct 2015 05:15:31 -0700 (PDT)
Message-ID: <20151012.051531.496968111040791414.davem@davemloft.net>
References: <1444351297-22614-1-git-send-email-richard@weltraumpflege.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org
To: richard@weltraumpflege.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbbJLL7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 07:59:44 -0400
In-Reply-To: <1444351297-22614-1-git-send-email-richard@weltraumpflege.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Sailer <richard@weltraumpflege.org>
Date: Fri,  9 Oct 2015 02:41:37 +0200

> The alive parameter of tcp_orphan_retries, indicates
> whether the connection is assumed alive or not.
> In the function and all places calling it is used as a boolean value.
> 
> Therefore this changes the type of alive to bool in the function
> definition and all calling locations.
> 
> Since tcp_orphan_tries is a tcp_timer.c local function no change in
> any other file or header is necessary.
> 
> Signed-off-by: Richard Sailer <richard@weltraumpflege.org>

Applied to net-next, thanks.

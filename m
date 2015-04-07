From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: RFC7413 option support for Fast Open
 client
Date: Tue, 07 Apr 2015 18:40:02 -0400 (EDT)
Message-ID: <20150407.184002.19148029458289443.davem@davemloft.net>
References: <1428356247-10262-1-git-send-email-ycheng@google.com>
	<1428356247-10262-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Longinus00@gmail.com, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbbDGWkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:40:04 -0400
In-Reply-To: <1428356247-10262-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  6 Apr 2015 14:37:27 -0700

> From: Daniel Lee <Longinus00@gmail.com>
> 
> Fast Open has been using an experimental option with a magic number
> (RFC6994). This patch makes the client by default use the RFC7413
> option (34) to get and send Fast Open cookies.  This patch makes
> the client solicit cookies from a given server first with the
> RFC7413 option. If that fails to elicit a cookie, then it tries
> the RFC6994 experimental option. If that also fails, it uses the
> RFC7413 option on all subsequent connect attempts.  If the server
> returns a Fast Open cookie then the client caches the form of the
> option that successfully elicited a cookie, and uses that form on
> later connects when it presents that cookie.
> 
> The idea is to gradually obsolete the use of experimental options as
> the servers and clients upgrade, while keeping the interoperability
> meanwhile.
> 
> Signed-off-by: Daniel Lee <Longinus00@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.

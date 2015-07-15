From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Avoid link dependency of dlm on sctp module
Date: Wed, 15 Jul 2015 13:59:18 -0700 (PDT)
Message-ID: <20150715.135918.1121936842089030351.davem@davemloft.net>
References: <cover.1436891629.git.marcelo.leitner@gmail.com>
	<20150715135714.GB24091@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbbGOU7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 16:59:19 -0400
In-Reply-To: <20150715135714.GB24091@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 15 Jul 2015 09:57:14 -0400

> Series
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

I don't like this at all.

I know it's a pain in the ass to have this dependency on SCTP, but
calling exported functions is absolutely the right way to handle
this kind of situation.

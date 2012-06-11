From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: Fix clock en-/disable calls
Date: Mon, 11 Jun 2012 16:50:05 -0700 (PDT)
Message-ID: <20120611.165005.1297137729728029316.davem@davemloft.net>
References: <1339147265-19188-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viresh.linux@gmail.com,
	peppe.cavallaro@st.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab2FKXuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:50:06 -0400
In-Reply-To: <1339147265-19188-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Fri,  8 Jun 2012 11:21:05 +0200

> clk_{un}prepare is mandatory for platforms using common clock framework.
> Since these drivers are used by SPEAr platform, which supports common
> clock framework, add clk_{un}prepare() support for them. Otherwise
> the clocks are not correctly en-/disabled and ethernet support doesn't
> work.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>

Applied, thanks.

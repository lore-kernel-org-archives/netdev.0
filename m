From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: use sizeof instead of constant in
 spkt_device
Date: Mon, 11 Jun 2012 16:52:26 -0700 (PDT)
Message-ID: <20120611.165226.526660267410221047.davem@davemloft.net>
References: <4FD4EE90.1070302@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab2FKXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:52:26 -0400
In-Reply-To: <4FD4EE90.1070302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Sun, 10 Jun 2012 20:59:28 +0200

> This small patch removes access to the last element of the spkt_device
> array through a constant. Instead, it is accessed by sizeof() to respect
> possible changes in if_packet.h.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Applied, thanks.

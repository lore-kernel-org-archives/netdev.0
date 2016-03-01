From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v3.16]r8169: Keep minimum barrier on coherent
 allocation
Date: Tue, 1 Mar 2016 21:50:32 +0100
Message-ID: <20160301205032.GA30997@electric-eye.fr.zoreil.com>
References: <1456849931-9533-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60397 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbcCAUuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:50:35 -0500
Content-Disposition: inline
In-Reply-To: <1456849931-9533-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <asd@marian1000.go.ro> :
> This patch add 256 Bytes barrier on rx/tx coherent allocations.

It does not make much sense unless you want to use a non power of two
value for NUM_.._DESC or a value < 16 with some strange kernel where
dma_alloc_coherent does not provide page alignment.

-- 
Ueimor

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/53] netns xfrm: per-netns xfrm_state_all list
Date: Tue, 25 Nov 2008 17:16:18 -0800 (PST)
Message-ID: <20081125.171618.203077207.davem@davemloft.net>
References: <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-3-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-4-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752424AbYKZBQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:16:18 -0500
In-Reply-To: <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:26:36 +0300

> This is done to get
> a) simple "something leaked" check
> b) cover possible DoSes when other netns puts many, many xfrm_states
>    onto a list.
> c) not miss "alien xfrm_state" check in some of list iterators in future.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

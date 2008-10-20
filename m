From: David Miller <davem@davemloft.net>
Subject: Re: [BUG-FIX][PATCH] tcp: Fix IPv6 fallout from 'Port redirection
 support for TCP'
Date: Sun, 19 Oct 2008 23:36:09 -0700 (PDT)
Message-ID: <20081019.233609.78658114.davem@davemloft.net>
References: <200810181209.10355@nessa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbYJTGgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 02:36:32 -0400
In-Reply-To: <200810181209.10355@nessa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Sat, 18 Oct 2008 12:09:10 +0200

> tcp: Fix IPv6 fallout from 'Port redirection support for TCP'
> 
> 'tcp: Port redirection support for TCP' (a3116ac5c) added a new member
> to inet_request_sock() which inet_csk_clone() makes use of but failed
> to add proper initialization to the IPv6 syncookie code and missed a
> couple of places where the new member should be used instead of
> inet_sk(sk)->sport.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Applied, thanks.

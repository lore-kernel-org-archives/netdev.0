From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] acenic: Pass up error code from ace_load_firmware()
Date: Mon, 12 Oct 2009 04:19:09 -0700 (PDT)
Message-ID: <20091012.041909.195263696.davem@davemloft.net>
References: <1255311286.2488.11.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, linux-acenic@sunsite.dk,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182AbZJLLTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 07:19:13 -0400
In-Reply-To: <1255311286.2488.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 12 Oct 2009 02:34:46 +0100

> If ace_load_firmware() fails, ace_init() cleans up but still returns
> 0, leading to an oops as seen in <http://bugs.debian.org/521383>.
> It should pass the error code up.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, and I'll queue this up for -stable, thanks!

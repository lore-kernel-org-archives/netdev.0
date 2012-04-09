From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 04/26] typhoon: get rid of redundant conditional before
 all to release_firmware()
Date: Mon, 09 Apr 2012 17:03:09 -0400
Message-ID: <1334005389.1744.4.camel@frustration.ornl.gov>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
	 <alpine.LNX.2.00.1204092208140.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	netdev@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta02.ornl.gov ([128.219.14.62]:35172 "EHLO mta02.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab2DIVDL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 17:03:11 -0400
In-Reply-To: <alpine.LNX.2.00.1204092208140.13925@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 22:50 +0200, Jesper Juhl wrote:
> There's no need to test for a NULL pointer before calling
> release_firmware() since the function does that check itself, so
> remove the redundant test.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

FWIW on a trivial patch,

Acked-by: David Dillow <dave@thedillows.org>

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tulip: remove wrapper around get_unaligned
Date: Fri, 27 Jun 2008 02:10:05 -0400
Message-ID: <4864843D.7070203@garzik.org>
References: <1212018664.20781.9.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41272 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758364AbYF0GKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:10:08 -0400
In-Reply-To: <1212018664.20781.9.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> DE_UNALIGNED_16 is always being passed a u16 *, no need to have the
> wrapper with two casts in it, just call get_unaligned directly.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/tulip/de2104x.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)

applied



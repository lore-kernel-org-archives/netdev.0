From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] sky2: restore multicast addresses after recovery
Date: Wed, 30 Jan 2008 03:51:10 -0500
Message-ID: <47A03A7E.2070904@pobox.com>
References: <20080123191151.1423a045@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33519 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589AbYA3IvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:51:11 -0500
In-Reply-To: <20080123191151.1423a045@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> If the sky2 deadman timer forces a recovery, the multicast hash
> list is lost. Move the call to sky2_set_multicast to the end
> of sky2_up() so all paths that bring device up will restore multicast.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
> Please apply for 2.6.24

applied 1-2

You'll want to send this to stable@kernel.org, since by the time I read 
your mail, 2.6.24 had been released, just around 24 hours thereafter.



From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] sky2: handle network device allocation failure
Date: Wed, 31 Jan 2007 05:03:04 -0500
Message-ID: <45C06958.30309@garzik.org>
References: <20070126193835.658962000@linux-foundation.org> <20070126194004.028526000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55349 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932928AbXAaKDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:03:07 -0500
In-Reply-To: <20070126194004.028526000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@linux-foundation.org wrote:
> If alloc_etherdev() failed, then sky2_init_netdev will return NULL,
> and sky2_probe would end up returning 0 instead of -ENOMEM.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied



From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] myri10ge: write as 2 32-byte blocks in myri10ge_submit_8rx
Date: Mon, 04 Dec 2006 18:36:25 -0500
Message-ID: <4574B0F9.9070409@garzik.org>
References: <4573F8ED.3050304@myri.com> <4573F97B.90707@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39498 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967811AbWLDXg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:36:27 -0500
To: Brice Goglin <brice@myri.com>
In-Reply-To: <4573F97B.90707@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> In the myri10ge_submit_8rx() routine, write the 64 byte request block as
> 2 32-byte blocks so that it is handled by the hardware pio write handler
> if write-combining is enabled.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

ACK, can you resend due to patch collision in #upstream?

	Jeff




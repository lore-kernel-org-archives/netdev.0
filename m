From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Tue, 22 Jul 2008 16:09:23 -0400
Message-ID: <48863E73.9000404@garzik.org>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48683 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073AbYGVUJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 16:09:27 -0400
In-Reply-To: <48844831.9040102@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Switch to ioremap_wc(). We keep the MTRR code since ioremap_wc()
> will use UC_MINUS when falling back to uncachable, and thus let
> the MTRR WC take precedence.
> 
> Also rename the error path better.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

applied 1-2



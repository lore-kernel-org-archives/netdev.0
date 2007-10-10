From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: Use NATSEMI_TIMER_FREQ consistently
Date: Tue, 09 Oct 2007 20:47:20 -0400
Message-ID: <470C2118.1060101@pobox.com>
References: <1191967059-7143-1-git-send-email-broonie@sirena.org.uk> <1191967059-7143-2-git-send-email-broonie@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thockin@hockin.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46674 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492AbXJJArX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:47:23 -0400
In-Reply-To: <1191967059-7143-2-git-send-email-broonie@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> The natsemi driver has a define NATSEMI_TIMER_FREQ which looks like it
> controls the normal frequency of the chip poll timer but in fact only
> takes effect for the first run of the timer.  Adjust the value of the
> define to match that used by the timer and use the define consistently.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>
> ---
>  drivers/net/natsemi.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied



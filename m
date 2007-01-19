From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] make hdlc_setup() static again
Date: Thu, 18 Jan 2007 22:01:43 -0500
Message-ID: <45B03497.6020502@garzik.org>
References: <20070111134859.GD20027@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Krzysztof Halasa <khc@pm.waw.pl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47641 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932868AbXASDBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:01:51 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20070111134859.GD20027@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> hdlc_setup was exported, but this export was never used.
> 
> If a driver using it actually shows up it can still be exported again.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>

applied



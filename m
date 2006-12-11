From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] chelsio: working NAPI
Date: Mon, 11 Dec 2006 09:51:17 -0500
Message-ID: <457D7065.6020105@pobox.com>
References: <20061208110833.1988ca8e@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Marti <felix@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46442 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760652AbWLKOvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:51:20 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061208110833.1988ca8e@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This driver tries to enable/disable NAPI at runtime, but 
> does so in an unsafe manner, and the NAPI interrupt handling is
> a mess. Replace it with a compile time selected NAPI implementation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied



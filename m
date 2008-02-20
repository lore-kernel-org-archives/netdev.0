From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] sis190: read the mac address from the eeprom first
Date: Wed, 20 Feb 2008 11:52:05 -0500
Message-ID: <47BC5AB5.8020309@garzik.org>
References: <20080218202032.GA2565@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	dsd@gentoo.org, "Gabriel A. Devenyi" <ace@staticwave.ca>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48853 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758221AbYBTQwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:52:09 -0500
In-Reply-To: <20080218202032.GA2565@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Reading a serie of zero from the cmos sram area do not work
> well with is_valid_ether_addr(). Let's read the mac address
> from the eeprom first as it seems more reliable.
> 
> Fix for http://bugzilla.kernel.org/show_bug.cgi?id=9831
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/sis190.c |   15 ++++++++++-----
>  1 files changed, 10 insertions(+), 5 deletions(-)

applied



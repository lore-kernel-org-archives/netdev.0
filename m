From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] skge: fix transmitter flow control
Date: Tue, 27 Feb 2007 04:17:05 -0500
Message-ID: <45E3F711.1040501@pobox.com>
References: <20070223140300.1c93a375@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47397 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161076AbXB0JRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:17:07 -0500
In-Reply-To: <20070223140300.1c93a375@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It looks like the skge driver inherited another bug from the sk98lin code.
> If I send from 1000mbit port to a machine on 100mbit port, the switch should
> be doing hardware flow control, but no pause frames show up in the statistics.
> 
> This is the analog of the recent sky2 fixes. The device needs to listen
> for multicast pause frames and then not discard them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/skge.c |   43 ++++++++++++++++++++++++++++++++-----------
>  drivers/net/skge.h |    3 +--
>  2 files changed, 33 insertions(+), 13 deletions(-)

applied



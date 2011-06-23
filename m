From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: unintended ipv4 broadcast policy change
Date: Thu, 23 Jun 2011 08:16:14 -0700
Message-ID: <20110623081614.213a432f@nehalam.ftrdhcpuser.net>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47489 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758206Ab1FWPQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 11:16:17 -0400
In-Reply-To: <20110622.163935.2248705300315908767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2011 16:39:35 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> But debian definitely still has this bug.  On debian, as a result,
> every packet received gets parsed.

Are you saying the DHCP client ends up parsing every packet?
This doesn't appear to be true.

I checked and the dhclient spends its life waiting on select for DHCP port.

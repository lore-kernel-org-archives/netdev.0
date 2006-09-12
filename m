From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Tue, 12 Sep 2006 12:08:03 -0400
Message-ID: <4506DB63.2040904@pobox.com>
References: <20060908111613.12c1f9b8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22753 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030264AbWILQII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 12:08:08 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060908111613.12c1f9b8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The ethtool_ops structure is immutable, it expected to be setup
> by the driver and is never changed. This patch allows drivers to
> declare there ethtool_ops structure read-only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

ACK, but I need the associated change-all-drivers patch, in order to 
apply this.

	Jeff



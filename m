From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Wed, 13 Sep 2006 11:08:44 +0900
Message-ID: <20060913110844.42623dcb@localhost.localdomain>
References: <20060908111613.12c1f9b8@localhost.localdomain>
	<4506DB63.2040904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48800 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751497AbWIMCJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:09:48 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4506DB63.2040904@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Sep 2006 12:08:03 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > The ethtool_ops structure is immutable, it expected to be setup
> > by the driver and is never changed. This patch allows drivers to
> > declare there ethtool_ops structure read-only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> ACK, but I need the associated change-all-drivers patch, in order to 
> apply this.
> 
> 	Jeff
> 
> 

No, they can pass non-const and everthing works.
Changing the ethtool_ops to have const args would require a global change.

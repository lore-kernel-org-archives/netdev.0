From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] ethtool: allow const ethtool_ops
Date: Tue, 12 Sep 2006 22:12:30 -0400
Message-ID: <4507690E.2030804@pobox.com>
References: <20060908111613.12c1f9b8@localhost.localdomain>	<4506DB63.2040904@pobox.com> <20060913110844.42623dcb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13190 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751499AbWIMCMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:12:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060913110844.42623dcb@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> No, they can pass non-const and everthing works.
> Changing the ethtool_ops to have const args would require a global change.

Re-stating previous email:  I need a patch which updates all drivers to 
declare their ethtool_ops structs const.

	Jeff



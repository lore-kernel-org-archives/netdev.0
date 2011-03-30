From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ethtool physical identify vs netlink locking?
Date: Tue, 29 Mar 2011 17:23:51 -0700
Message-ID: <20110329172351.598dd346@s6510>
References: <20110329135252.116bf5e0@s6510>
	<1301443676.10056.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab1C3AXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 20:23:53 -0400
In-Reply-To: <1301443676.10056.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Mar 2011 01:07:56 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> 4. Define a ethtool operation 'set_id_state' with an argument that sets

I like this way, but the code should return -EINTR if interrupted?

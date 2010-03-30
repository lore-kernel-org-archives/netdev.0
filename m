From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 10:32:07 -0700
Message-ID: <20100330103207.7fc5681a@nehalam>
References: <20100328154448.701c89ee@nehalam>
	<20100329174727.4654e19c@nehalam>
	<20100329175352.38008e05@nehalam>
	<4BB234DD.9040800@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33675 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778Ab0C3Rca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:32:30 -0400
In-Reply-To: <4BB234DD.9040800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 13:29:01 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY 
> and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed, 
> breaking the ethtool build.

In the patch I moved it to ethtool.c to have local entries.

I believe that all cloned headers should only come from the result
of kernel "make install_headers".  Not locally different vrsions.


-- 

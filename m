From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 06/12] netxen: module params for ring sizes
Date: Mon, 27 Jul 2009 10:31:59 -0700 (PDT)
Message-ID: <20090727.103159.11604810.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-7-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751535AbZG0Rbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:31:53 -0400
In-Reply-To: <1248674867-18821-7-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:41 -0700

> Add module parameters to set rx, jumbo and tx ring sizes
> globally. 1GbE and 10GbE ports can have different ring
> sizes.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

We do not add module parameters for stuff like this.

Invoke ethtool early enough, by whatever means, to set
such things as desired.

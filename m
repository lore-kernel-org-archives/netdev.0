From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: add IntMode module parameter
Date: Mon, 22 Mar 2010 18:28:27 -0700 (PDT)
Message-ID: <20100322.182827.180417968.davem@davemloft.net>
References: <20100323000519.19902.14802.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756256Ab0CWB2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 21:28:06 -0400
In-Reply-To: <20100323000519.19902.14802.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 22 Mar 2010 17:06:20 -0700

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> This patch adds the IntMode module parameter to igb. This
> allows user selection of interrupt mode (MSI-X, MSI, legacy)
> on driver load.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

And IGB is special and needs this for what reason?

If there are real interrupt issues then:

1) Diagnosing via verification of the problem can be simply performed
   by asking the user to pass the generic kernel boot option to
   globally disable MSI and friends.

2) Specifically disabling it for buggy parts belongs in the
   driver or in the PCI quirk tables.

So from just about any angle, this module option makes no sense.

So I'm not applying it, sorry.

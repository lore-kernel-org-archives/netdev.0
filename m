From: David Miller <davem@davemloft.net>
Subject: Re: Patches for hso driver
Date: Wed, 18 Nov 2009 10:01:45 -0800 (PST)
Message-ID: <20091118.100145.80625674.davem@davemloft.net>
References: <DDA9430807DF40968BE983465235D580@mschille2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mschiller@tdt.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758153AbZKRSB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:01:28 -0500
In-Reply-To: <DDA9430807DF40968BE983465235D580@mschille2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Martin Schiller" <mschiller@tdt.de>
Date: Wed, 18 Nov 2009 08:35:30 +0100

> Have a look at the "hso-memleak.patch" file to see what I mean.

Hmmm...

Please make sure this all works properly, considering
the games that hso_kick_transmit() plays wherein it
swaps ->tx_data and ->tx_buffer every packet send.

Also, please submit your patches sperately and numbered
with changelog and signoffs specific to each change as
described in  linux/Documentation/SubmittingPatches 

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] qlcnic: NIC Partitioning - Add basic
 infrastructure support
Date: Wed, 02 Jun 2010 02:23:21 -0700 (PDT)
Message-ID: <20100602.022321.209988583.davem@davemloft.net>
References: <alpine.OSX.2.00.1006011422230.45836@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com,
	ameen.rahman@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754931Ab0FBJXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:23:12 -0400
In-Reply-To: <alpine.OSX.2.00.1006011422230.45836@macintosh-2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Tue, 1 Jun 2010 14:28:51 -0700

> Following changes have been added to enable the adapter to work in
> NIC partitioning mode where multiple PCI functions of an adapter port can
> be configured to work as NIC functions. The first function that is enumerated on
> the PCI bus assumes the role of management function which, besides being able
> to do all the NIC functionality, can configure other NIC partitions. Other NIC
> functions can be configured as privileged or non privileged functions.
> Privileged function can not configure other NIC functions but can do all the
> NIC functionality including any firmware initialization, chip reset etc. Non
> privileged functions can do only basic IO. For chip reset etc, it depends on the
> privilege or management function.
> 
> 1. Added code to determine PCI function number independent of kernel API.
> 2. Added Driver - FW version 2.0 support.
> 3. Changed producer and consumer register offset calculation.
> 4. Added management and privileged operation modes for npar functions. A module
>  parameter has been added to control it.
> 5. Added support for configuring the eswitch in the adapter.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.

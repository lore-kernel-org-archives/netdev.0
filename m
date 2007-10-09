From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 14:25:04 -0700 (PDT)
Message-ID: <20071009.142504.116349168.davem@davemloft.net>
References: <470B77A9.600@garzik.org>
	<20071009.131438.74562715.davem@davemloft.net>
	<470BE27E.4000101@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753558AbXJIVZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 17:25:04 -0400
In-Reply-To: <470BE27E.4000101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 09 Oct 2007 16:20:14 -0400

> David Miller wrote:
> > If you unconditionally take those locks in the transmit function,
> > there is probably an ABBA deadlock elsewhere in the driver now, most
> > likely in the TX reclaim processing, and you therefore need to handle
> > that too.
> 
> And I most certainly checked the relevant transmit paths and other 
> locking to make sure lock ordering was correct.

Awesome.

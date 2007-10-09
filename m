From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 04:24:41 -0700 (PDT)
Message-ID: <20071009.042441.30182968.davem@davemloft.net>
References: <20071009.040255.71088090.davem@davemloft.net>
	<OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751873AbXJILYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 07:24:41 -0400
In-Reply-To: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Tue, 9 Oct 2007 16:51:14 +0530

> David Miller <davem@davemloft.net> wrote on 10/09/2007 04:32:55 PM:
> 
> > Ignore LLTX, it sucks, it was a big mistake, and we will get rid of
> > it.
> 
> Great, this will make life easy. Any idea how long that would take?
> It seems simple enough to do.

I'd say we can probably try to get rid of it in 2.6.25, this is
assuming we get driver authors to cooperate and do the conversions
or alternatively some other motivated person.

I can just threaten to do them all and that should get the driver
maintainers going :-)


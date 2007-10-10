From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 15:53:22 -0700 (PDT)
Message-ID: <20071010.155322.43010360.davem@davemloft.net>
References: <1191967006.5324.14.camel@localhost>
	<20071009.170435.43504422.davem@davemloft.net>
	<20071010120215.7ec19323.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@linux-foundation.org,
	andi@firstfloor.org, jeff@garzik.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com, kaber@trash.net
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756538AbXJJWxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:53:20 -0400
In-Reply-To: <20071010120215.7ec19323.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Wed, 10 Oct 2007 12:02:15 -0400

> On Tue, 09 Oct 2007, David Miller wrote:
> 
> > We have to keep in mind, however, that the sw queue right now is 1000
> > packets.  I heavily discourage any driver author to try and use any
> > single TX queue of that size.  Which means that just dropping on back
> > pressure might not work so well.
> > 
> > Or it might be perfect and signal TCP to backoff, who knows! :-)
> 
> I can't remember the details anymore, but for 10-GigE, I have encountered
> cases where I was able to significantly increase TCP performance by
> increasing the txqueuelen to 10000, which is the setting I now use for
> any 10-GigE testing.

For some reason this does not surprise me.

We bumped the ethernet default up to 1000 for gigabit.

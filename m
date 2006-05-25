From: Bill Fink <billfink@mindspring.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 03:55:06 -0400
Message-ID: <20060525035506.2f229b64.billfink@mindspring.com>
References: <20060523.182217.59656237.davem@davemloft.net>
	<447412CA.50303@ipom.com>
	<4474A489.4080308@garzik.org>
	<20060524185644.GF22881@ipom.com>
	<4474AE92.3030501@garzik.org>
	<20060524191442.GG22881@ipom.com>
	<1148501433.5325.52.camel@jzny2>
	<20060524204800.GH22881@ipom.com>
	<4474CA66.5020401@hp.com>
	<4474CBAA.4040307@candelatech.com>
	<44753A3B.5010204@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, rick.jones2@hp.com, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth04.mail.atl.earthlink.net ([209.86.89.64]:50912 "EHLO
	smtpauth04.mail.atl.earthlink.net") by vger.kernel.org with ESMTP
	id S965019AbWEYHzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 03:55:13 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <44753A3B.5010204@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006, Phil Dibowitz wrote:

> Right. I think the point here is that it does _NOT_ inherently break
> things. If you don't like the behavior, don't run "ethtool -z eth0",
> it's that simple.
> 
> A co-worker suggested today, that maybe it'd appease people if the final
> ethtool patch made it a capitol option that you can only run by itself.
> I.e. if you can't call it with anything else, it's more difficult to
> call my accident. I'd be willing to this.

I think that's a good idea.  Since it is changing (zeroing) the stats,
it probably should be a capitol option.

						-Bill

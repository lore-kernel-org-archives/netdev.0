From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three
Date: Tue, 16 Oct 2007 17:00:57 +0200
Message-ID: <1192546857.29746.182.camel@eliezer>
References: <p73641c4cfz.fsf@bingen.suse.de>
 <20071012.150341.41635825.davem@davemloft.net>
 <1192462049.29746.158.camel@eliezer>
 <20071015.123850.26516814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, jeff@garzik.org,
	mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3062 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757355AbXJPO7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 10:59:35 -0400
In-Reply-To: <20071015.123850.26516814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-15 at 12:38 -0700, David Miller wrote:
> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Mon, 15 Oct 2007 17:27:29 +0200
> 
> > Unfortunately, the firmware code is different for LE and BE machines.
> > We had issues with the BE firmware that appear to be resolved.
> > Hopefully, the next version will have both.
> 
> If this means we get two copies of the firmware, this should be
> rethought.  The space cost of the firmware (both in terms of source
> code size and object code size) is already enormous.
> 
> I would definitely prefer if there were only little-endian firmware,
> and the driver uses "cpu_to_le32()" and friends to access chip shared
> data structures.

OK. Then that's what we will do.



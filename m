From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][LAPB] write_queue limit in lapb_data_request
Date: Fri, 28 Mar 2008 18:30:52 -0700 (PDT)
Message-ID: <20080328.183052.72394821.davem@davemloft.net>
References: <8496f91a0803250045k2fc4040dg74126f30c1487fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753615AbYC2Baw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:30:52 -0400
In-Reply-To: <8496f91a0803250045k2fc4040dg74126f30c1487fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Date: Tue, 25 Mar 2008 10:45:41 +0300

> LAPB doesn't check for write_queue length in lapb_data_request(). So
> in some conditions it may grow unlimited. There is a potential problem
> for small systems.
> 
> It seems like this for me:

It doesn't enforce limits on any of it's queued from what
I can tell.

Without a thorough audit of resource limit enforcement in
this protocol stack, changing things here might be more
trouble than it's worth.

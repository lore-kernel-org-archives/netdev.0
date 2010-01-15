From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netxen: endianness fixes
Date: Thu, 14 Jan 2010 16:54:38 -0800 (PST)
Message-ID: <20100114.165438.39939357.davem@davemloft.net>
References: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
	<20100114.030854.52825026.davem@davemloft.net>
	<821ABD80-7BA0-4A8B-B7DC-87D3B0BA9ADF@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45432
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755469Ab0AOAy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 19:54:28 -0500
In-Reply-To: <821ABD80-7BA0-4A8B-B7DC-87D3B0BA9ADF@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Thu, 14 Jan 2010 06:57:47 -0800

> 
> On Jan 14, 2010, at 3:08 AM, David Miller wrote:
> 
>> You mean in all this time, nobody noticed that reading the MAC
>> address isn't done correctly on big-endian?
>> 
>> Well then I guess all of these small endianness fixes aren't
>> very critical this late in the RC series.
> 
> The MAC fix doesn't change any functionality, just changing data types.
> It was working on big-endian machines.

Then that's a cleanup and thus even less appropriate for net-2.6

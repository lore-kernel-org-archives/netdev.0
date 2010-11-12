From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Prevent crashing when parsing bad X.25 facilities
Date: Fri, 12 Nov 2010 12:45:32 -0800 (PST)
Message-ID: <20101112.124532.15255032.davem@davemloft.net>
References: <1289594548.3090.334.camel@Dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, netdev@vger.kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751767Ab0KLUpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:45:08 -0500
In-Reply-To: <1289594548.3090.334.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Fri, 12 Nov 2010 15:42:28 -0500

> Now with improved comma support.
> 
> On parsing malformed X.25 facilities, decrementing the remaining length
> may cause it to underflow.  Since the length is an unsigned integer,
> this will result in the loop continuing until the kernel crashes.
> 
> This patch adds checks to ensure decrementing the remaining length does
> not cause it to wrap around.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

Applied.

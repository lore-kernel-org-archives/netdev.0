From: David Miller <davem@davemloft.net>
Subject: Re: [Devel] [PATCH 2.6.25] [IPV4] Reduce whitespaces in
 fib_rules.h.
Date: Thu, 13 Dec 2007 06:49:55 -0800 (PST)
Message-ID: <20071213.064955.91784038.davem@davemloft.net>
References: <20071213141842.GA9939@iris.sw.ru>
	<20071213144707.GB6209@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org,
	devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752905AbXLMOt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 09:49:58 -0500
In-Reply-To: <20071213144707.GB6209@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Thu, 13 Dec 2007 17:47:07 +0300

> On Thu, Dec 13, 2007 at 05:18:42PM +0300, Denis V. Lunev wrote:
> > There are to many spaces between type and function name in the declaration
> > of fib rules manipulation routines. Eat them and save a couple of lines.
> 
> If this patch is going in, it would be nice to get rid of "extern" as
> well.

The convention in the networking headers is to use extern, and
this is pretty consistently done across the board.

If we are going to do this, which I personally see no reason
for, we should do it across the whole networking.

Consistency is much more important than whatever reason you
could come up with to get rid of the 'extern'.

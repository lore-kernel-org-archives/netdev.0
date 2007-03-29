From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Inline net_device_stats
Date: Thu, 29 Mar 2007 10:00:36 +1000
Message-ID: <1175126436.12230.62.camel@localhost.localdomain>
References: <1175073418.12230.52.camel@localhost.localdomain>
	 <460A8F38.1050106@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38758 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965881AbXC2AA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 20:00:58 -0400
In-Reply-To: <460A8F38.1050106@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-28 at 08:52 -0700, Stephen Hemminger wrote:
> It would make sense to do it per-cpu and 64 bit for the non-error counters.

Well, I looked at the e1000, it doesn't update on every packet anyway,
but seems to d/l from the card occasionally.  I assume this is the
method for high-speed drivers, otherwise we should split the tx & rx
parts of the structure.

64 bit introduces potential compatibility problems (exporting via proc).
And per-cpu feels like overkill to me.

Rusty.


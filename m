From: David Miller <davem@davemloft.net>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Thu, 13 Mar 2008 05:53:22 -0700 (PDT)
Message-ID: <20080313.055322.193703258.davem@davemloft.net>
References: <20080312151051.GI26963@solarflare.com>
	<20080312.204145.202573599.davem@davemloft.net>
	<20080313114717.GM24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse.brandeburg@intel.com, maxk@qualcomm.com,
	netdev@vger.kernel.org, rostedt@goodmis.org, mingo@elte.hu
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752240AbYCMMxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 08:53:13 -0400
In-Reply-To: <20080313114717.GM24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 13 Mar 2008 11:47:19 +0000

> The specific part I was referring to was:
> 
>    "This scheme can be further improved upon, if the host tells the driver what
>     CPU it wished to run a particular session on. With this information, the
>     driver can steer a session to the same CPU that the scheduler runs the
>     socket reads on, and achieve the best cache locality for both kernel and
>     user level rx processing."
> 
> So far as I'm aware, this hasn't been done.  If it has, I would love to know
> how to work with it.

That bit is not implemented, no.

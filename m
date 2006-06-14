From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 13:52:16 -0700
Message-ID: <1150318336.20846.22.camel@w-sridhar2.beaverton.ibm.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
	 <20060613140716.6af45bec@localhost.localdomain>
	 <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com>
	 <20060614133022.GU11863@sunbeam.de.gnumonks.org>
	 <44904C08.6020307@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, bidulock@openss7.org,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:31439 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932292AbWFNUxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 16:53:04 -0400
To: Daniel Phillips <phillips@google.com>, davem@davemloft.net
In-Reply-To: <44904C08.6020307@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-14 at 10:48 -0700, Daniel Phillips wrote:

> 
> Did we settle the question of whether these particular exports should be
> EXPORT_SYMBOL_GPL?

When i submitted this patch, i didn't really think about the different
ways to export these symbols. I simply used the EXPORT_SYMBOL() that is 
used by all the other exports in net/socket.c including kernel_sendmsg()
and kernel_recvmsg().

I am OK with either option(EXPORT_SYMBOL or EXPORT_SYMBOL_GPL) and i will
leave it to David Miller to make that decision at this point.

Thanks
Sridhar


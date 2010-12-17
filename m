From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev_alloc_name: fix kernel-doc formatting, typos, etc.
Date: Fri, 17 Dec 2010 13:53:55 -0800
Message-ID: <20101217135355.1f88ffff@nehalam>
References: <20101217134046.61eb94dd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754817Ab0LQVyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 16:54:00 -0500
In-Reply-To: <20101217134046.61eb94dd.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Dec 2010 13:40:46 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> - *	Passed a format string - eg "lt%d" it will try and find a suitable
> + *	Passed a format string - e.g. "lt%%d", it will try to find a suitable

This is wrong.
The obvious case of:
  alloc_etherdev() ends up calling __dev_alloc_name with "eth%d"
in fact __dev_alloc_name called with "lt%%d" will return -EINVAL


-- 

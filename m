From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fw: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Fri, 16 Feb 2007 18:28:58 +0300
Message-ID: <20070216152858.GA22020@2ka.mipt.ru>
References: <20070215160405.3bd30b05@localhost.localdomain> <20070216152557.GA20641@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37124 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945927AbXBPP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 10:29:16 -0500
Content-Disposition: inline
In-Reply-To: <20070216152557.GA20641@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 06:25:57PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Thu, Feb 15, 2007 at 04:04:05PM -0800, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> > Someone want to take a stab at fixing this??
> 
> Works for me with attached application - select on connreset socket
> immediately returns one ready descriptor.
> 
> $ ./a.out 192.168.0.48 22
> select: err: 1, errno: 0.
> write: err: 128, errno: 0.
> select: err: 1, errno: 0.
> write: err: 128, errno: 0.
> select: err: 1, errno: 0.
> write: err: -1, errno: 104.
> on exit: select: err: 1, errno: 104.

Nope, fails if file descriptor is checked for write.

-- 
	Evgeniy Polyakov

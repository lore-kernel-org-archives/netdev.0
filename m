From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 15:56:25 +0400
Message-ID: <20070803115624.GD5727@2ka.mipt.ru>
References: <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41844 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761497AbXHCL5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 07:57:13 -0400
Content-Disposition: inline
In-Reply-To: <46956.simon.1186140106@5ec7c279.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 12:21:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> Since the connection is considered closed, couldn't another socket re-use it?
> 
> Socket A: Recv data (unread)
> Socket A: Recv RST
> Socket B: Reuses connection (same IPs/ports)
> Socket A: Close
> 
> Wouldn't that disrupt socket B's use of the connection?

Then it will drop our data, since there were no appropriate handhsake.

> -- 
> Simon Arlott

-- 
	Evgeniy Polyakov

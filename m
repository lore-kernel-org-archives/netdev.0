From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 21:55:06 +0300
Message-ID: <20100226185506.GB13393@lenovo>
References: <20100226165104.GB5364@lenovo> <4B88076F.8030302@openvz.org> <20100226100102.0d52c6e9@nehalam> <20100226.100800.116618587.davem@davemloft.net> <20100226103003.097c39ec@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, xemul@openvz.org,
	bridge@linux-foundation.org, netdev@vger.kernel.org, den@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:36831 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965700Ab0BZSzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 13:55:11 -0500
Received: by fxm19 with SMTP id 19so420388fxm.21
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 10:55:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100226103003.097c39ec@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 10:30:03AM -0800, Stephen Hemminger wrote:
> On Fri, 26 Feb 2010 10:08:00 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Fri, 26 Feb 2010 10:01:02 -0800
> > 
> > > TCP connections are never really bound to device. TCP routing is
> > > flexible; if packets can get through, it doesn't care.
> > 
> > I think he might be talking about SO_BINDTODEVICE
> 
> What application does that with TCP?
> 

Seems g500i uses it http://goo.gl/5lIi (function open_tcp_socket),
which is either router firmware or kind of modile device.
But frankly -- this seems to be unrelated to a bridge.

	-- Cyrill

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 17:57:20 -0700
Message-ID: <20061012175720.004e82b9@localhost.localdomain>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
	<452E69B2.4030306@hp.com>
	<469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
	<452EC7B9.2030801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18838 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751366AbWJMA5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 20:57:32 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <452EC7B9.2030801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006 15:54:49 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> > More to the point, on what basis would the application be rejecting a
> > connection request based solely on the SYN?
> 
> True, it isn't like there would suddenly be any call user data as in XTI/TLI.
> 
> > There are only two pieces of information available: the remote IP
> > address and port, and the total number of pending requests. The
> > latter is already addressed through the backlog size, and netfilter
> > rules can already be used to reject based on IP address.
> 
> It would though allow an application to have an even more restricted set of 
> allowed IP's than was set in netfilter.  Rather like allowing the application to 
> set socket buffer sizes rather than relying on the system's default.
>

Some version of BSD sockets had this behaviour, perhaps you should use
the same model.  It was some socket option, I can't remember; what ever
it wasn't widely adopted. Nothing says you can't just use shutdown() to
force a RST on the addresses you don't want to talk to.

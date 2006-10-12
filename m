From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 15:54:49 -0700
Message-ID: <452EC7B9.2030801@hp.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com> <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:20413 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751268AbWJLWyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 18:54:51 -0400
To: Caitlin Bestler <caitlin.bestler@gmail.com>
In-Reply-To: <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> More to the point, on what basis would the application be rejecting a
> connection request based solely on the SYN?

True, it isn't like there would suddenly be any call user data as in XTI/TLI.

> There are only two pieces of information available: the remote IP
> address and port, and the total number of pending requests. The
> latter is already addressed through the backlog size, and netfilter
> rules can already be used to reject based on IP address.

It would though allow an application to have an even more restricted set of 
allowed IP's than was set in netfilter.  Rather like allowing the application to 
set socket buffer sizes rather than relying on the system's default.

rick jones

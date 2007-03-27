From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Problem with sockets an 2.6.21-rc5 kernel
Date: Tue, 27 Mar 2007 17:12:56 +0400
Message-ID: <20070327131256.GA7513@2ka.mipt.ru>
References: <200703262303.21448.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jose Alberto Reguero <jareguero@telefonica.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50833 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753841AbXC0NNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:13:16 -0400
Content-Disposition: inline
In-Reply-To: <200703262303.21448.jareguero@telefonica.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2007 at 11:03:21PM +0200, Jose Alberto Reguero (jareguero@telefonica.net) wrote:
> I had two python programs, server.py and client.py(attached)
> 
> With server.py in  a kernel 2.6.21-rc5 x86_64 and client.py in the same 
> machine,  server.py get the message.
> 
> With server.py in  a kerner 2.6.21-rc5 x86_64 and client.py in another 
> machine, server.py don't get the message.
> 
> The same with the programs in c(attached).
> 
> With kernel 2.6.20.3 the programs work well.
> 
> There are something wrong in the programs?

Besides full absence of error checks and coding style issues it does not
seem to contain errors.

And, btw, C program work with 2.6.21-rc5 (git tree
e0f2e3a06be513352cb4955313ed7e55909acd84) on x86_64.

server.c application compiled with Debian 4.1.1-21 compiler on x86_64
sucessfully received message from 2.6.18-3 machine.

-- 
	Evgeniy Polyakov

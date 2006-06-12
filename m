From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: link-local address via ifconfig
Date: Mon, 12 Jun 2006 16:02:07 +0200
Message-ID: <200606121602.08048.netdev@axxeo.de>
References: <20060603025743.GL549@progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:16537 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1751986AbWFLOCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 10:02:15 -0400
To: Anand Kumria <wildfire@progsoc.uts.edu.au>
In-Reply-To: <20060603025743.GL549@progsoc.uts.edu.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anand,

Anand Kumria wrote:
> There are plenty of people who still use ifconfig to list the addresses
> assigned to their network interfaces (I know, ifconfig is broken) and
> who then parse the output.
> 
> However the kernel puts link-local scoped address first if the address
> list of an interface, so an interface like:

> Is there any reason to put the link-local address first in the list?
> 
> I've had a number of bugreports (or outright panic attacks) where the 
> problem turned out to be that ifconfig was reporting the link-local 
> address first, rather than the global/site one.

This can be worked around by defining an "alias interface" this way
"ip address add 169.254.182.108/16 brd 169.254.255.255 scope link dev eth0 label eth0:0"
(see: "label eth0:0" is appended)

So in reality this is no problem for users.


Regards

Ingo Oeser

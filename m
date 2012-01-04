From: "Cloutier, Joseph (Joseph)" <joseph.cloutier@alcatel-lucent.com>
Subject: RE: "-w deadline" bug in ping/iputils- i will provide fix if you
 can tell me where owner of iputils is. Thanks.
Date: Wed, 4 Jan 2012 14:56:49 -0600
Message-ID: <7D3B6706FA74174B8C1AC24710890745136F3C8944@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
References: <7D3B6706FA74174B8C1AC24710890745136F1A0BF1@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "'torvalds@osdl.org'" <torvalds@osdl.org>
To: "'Linus Torvalds'" <torvalds@linux-foundation.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail2.lucent.com ([135.245.0.35]:46179 "EHLO
	ihemail2.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756910Ab2ADU5B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 15:57:01 -0500
In-Reply-To: <7D3B6706FA74174B8C1AC24710890745136F1A0BF1@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Cloutier, Joseph (Joseph)
Sent: Wednesday, January 04, 2012 3:55 PM
To: 'Linus Torvalds'; 'netdev@vger.kernel.org'
Cc: 'torvalds@osdl.org'
Subject: RE: "-w deadline" bug in ping/iputils- i will provide fix if
you can tell me where owner of iputils is. Thanks.


netdev@vger.kernel.org.

I have made a fix for the "-w deadline" issue to iputils-s20101006.tar.bz2.  There are 4 places in the code with the fix, identified by my name, Joe Cloutier- ALU.

There are 2 bugs fixed:
*       For flood pings if the "-w" option is set then more pings than "-c x" are sent out.
*       The "-w x" timer should be set after he last "-c x" ping is sent out.

Linux flood ping is an invaluable tool for us to use when trouble shooting wireless network problems.  It is a very fast way to verify things like PVC allocations, duplex miss-matches, fiber problems, egress queue settins, etc.

I have modified 2 ping versions (one an older one prior to the shared library change many years ago, and then Redhat 8.0 release), but my Management does not my copies released to our Customers because the code is "unsupported".

If you would accept these changes then I can direct our Customers to use the official Linux flood ping option.

I have tested the code using Linux release 14 and the latest gcc compiler.  It is doing what it should now.

Thanks, Joe Cloutier

Created with tar cjvf ...

-----Original Message-----
From: linus971@gmail.com [mailto:linus971@gmail.com]On Behalf Of Linus
Torvalds
Sent: Thursday, December 08, 2011 8:49 PM
To: Cloutier, Joseph (Joseph)
Cc: torvalds@osdl.org
Subject: Re: "-w deadline" bug in ping/iputils- i will provide fix if
you can tell me where owner of iputils is. Thanks.


On Thu, Dec 8, 2011 at 1:54 PM, Cloutier, Joseph (Joseph)
<joseph.cloutier@alcatel-lucent.com> wrote:
>

See

  http://www.skbuff.net/iputils/

afaik,

               Linus

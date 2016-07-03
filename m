From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Mon, 04 Jul 2016 08:49:31 +1000
Message-ID: <1467586171.7422.104.camel@kernel.crashing.org>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, yuvali@mellanox.com
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57457 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932198AbcGCXcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 19:32:10 -0400
In-Reply-To: <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-07-04 at 01:03 +0300, Or Gerlitz wrote:
> FWIW, talking to a colleague, he made a comment that some of the text
> above is wrong:
> 
> AENs are sent from NIC to BMC. Not from Host to BMC.

Just a typo in the commit message thankfully ;-)

> The traffic between a BMC and a NIC is over RBT if it is formatted as
> NC-SI packets. This is not over network traffic....

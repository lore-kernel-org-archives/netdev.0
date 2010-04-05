From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ethtool: add names of newer Marvell chips
Date: Mon, 5 Apr 2010 10:34:03 -0700
Message-ID: <20100405103403.2cde2af9@nehalam>
References: <20100402081632.5401cf2f@nehalam>
	<q2sdac45061004030020n28a1ad17p71ed2c074ebb6450@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Mark Ryden <markryde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57105 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755824Ab0DEReV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 13:34:21 -0400
In-Reply-To: <q2sdac45061004030020n28a1ad17p71ed2c074ebb6450@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Apr 2010 10:20:40 +0300
Mark Ryden <markryde@gmail.com> wrote:

> Hi,
> 
> > +       case 0xba:      printf("Yukon Ultra 2"); break;
> > +       case 0xbc:      printf("Yukon Optima"); break;
> 
> What about 0xbb?
> Is there ant reason for not using 0xbb for Yukon Optima?
> 
> Is it something with blackberry (bb)?  :-)

The value comes from a chip register.
The vendor hardware engineers didn't choose to use that version
yet.

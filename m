From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 6 Apr 2007 13:54:47 -0700
Message-ID: <20070406135447.112c182c@localhost>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
	<20070406133420.2f098bc6@localhost>
	<4616BDEA.1080502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35566 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbXDFVzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 17:55:41 -0400
In-Reply-To: <4616BDEA.1080502@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 06 Apr 2007 14:38:50 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > Why not implement a true virtual network rather than simple
> > tunnel pairs?
> >   
> What would a true virtual network do?  You mean with routers and such?

Rather than just a pair, you could do address matching of destination
address.

> 
> I use my redirect device (basically same as etun) to join virtual 
> routers together,
> but all of the virtual routing (and bridging, etc) logic is already in 
> the kernel
> and just has to be configured properly....
> 
> Ben
> 

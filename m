From: James Morris <jmorris@namei.org>
Subject: Re: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Sat, 17 Jun 2006 11:55:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606171151320.16944@d.namei>
References: <20060617035440.GA28169@jiayuguan.watson.ibm.com>
 <20060616211603.14547a1d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Catherine Zhang <cxzhang@watson.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jmorris@redhat.com, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:46024 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751668AbWFQPzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 11:55:09 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060616211603.14547a1d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Jun 2006, Stephen Hemminger wrote:

> This is so short, it would make sense to put it in scm.h
> and why not have it return the value instead of call by reference?
> Same goes for selinux_get_inode_sid

Actually, all of the SELinux API functions are like this, and I'm not sure 
why for void return methods (it's a good idea when they return errnos).

Once this area has settled down (post 2.6.18), I'm planning to do some 
cleanups for this API anyway, and can fix these all at the same time.


- James
-- 
James Morris
<jmorris@namei.org>

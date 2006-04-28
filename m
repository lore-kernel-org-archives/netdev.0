From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:49:15 -0700
Message-ID: <20060428124915.686911c1@localhost.localdomain>
References: <20060428172932.GB16916@2ka.mipt.ru>
	<20060428104118.6a056a59@localhost.localdomain>
	<20060428175538.GA13898@2ka.mipt.ru>
	<20060428.121636.54294183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54989 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751447AbWD1Tty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 15:49:54 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060428.121636.54294183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006 12:16:36 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 28 Apr 2006 21:55:39 +0400
> 
> > On Fri, Apr 28, 2006 at 10:41:18AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > > Second, introducing
> > > kevents, seems unnecessary and hasn't been accepted in the mainline.
> > 
> > kevent was never sent to lkml@ although it showed over 40% win over epoll for
> > test web server. Sending it to lkml@ is just jumping into ... not into
> > technical world, so I posted it first here, but without much attention
> > though.
> 
> Frankly I found kevents to be a very strong idea.

But there is this huge semantic overload of kevent, poll, epoll, aio,
regular sendmsg/recv, posix aio, etc.  

Perhaps a clean break with the socket interface is needed. Otherwise, there
are nasty complications with applications that mix old socket calls and new interface
on the same connection.

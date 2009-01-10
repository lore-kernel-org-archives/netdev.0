From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Sat, 10 Jan 2009 08:10:38 -0700
Message-ID: <1231600238.9095.8.camel@bling>
References: <1231351563.7109.130.camel@lappy>
	 <200901102148.54962.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11380 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbZAJPKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 10:10:45 -0500
In-Reply-To: <200901102148.54962.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-10 at 21:48 +1030, Rusty Russell wrote:
> On Thursday 08 January 2009 04:36:03 Alex Williamson wrote:
> > virtio_net: Add MAC fitler table support
> 
> Ah, I see.  You really want multiple mac addresses, not just multicast
> filtering?
> 
> Anthony, you think a control channel?  We can add a virtqueue, but it
> seems like a lot of work...

Right, a MAC filter table followed by a VLAN filter table.  I've got a
virtqueue control channel mostly coded up, I should have something to
send out early next week for comments.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.


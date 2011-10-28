From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: HSR support
Date: Fri, 28 Oct 2011 17:54:21 +0200
Message-ID: <20111028175421.339b7c49@s6510.linuxnetplumber.net>
References: <4E948A04.8060400@enea.com>
	<20111011112821.28cd3e51@nehalam.linuxnetplumber.net>
	<4E94D67A.9060207@enea.com>
	<4EA5738B.8080008@enea.com>
	<4EAACB7A.4090207@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36697 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043Ab1J1Py1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 11:54:27 -0400
In-Reply-To: <4EAACB7A.4090207@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Oct 2011 17:34:18 +0200
Arvid Brodin <arvid.brodin@enea.com> wrote:

> Ok, so after a lot of reading and looking through code I have this idea of a
> standalone solution:
> 
> 1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
>    physical Ethernet interfaces each (somewhat like the bridge code does, but
>    with precisely 2 interfaces slaved).

Please use the newer netlink interface and the master attribute for this
rather than inventing yet another ioctl.

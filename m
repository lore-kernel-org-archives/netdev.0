From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Patches required for 3.9 stable
Date: Mon, 17 Jun 2013 08:29:09 -0700
Message-ID: <20130617152909.GA20663@kroah.com>
References: <51BEC1C3.40109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, jwboyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38349 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab3FQP2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 11:28:32 -0400
Content-Disposition: inline
In-Reply-To: <51BEC1C3.40109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 03:58:59PM +0800, Jason Wang wrote:
> Hi Greg:
> 
> Please include the following commits into 3.9.y. Which fixes:
> 
> 1) Crash when sending GSO packets from untrusted sources
> 9b4d669bc06c215d64f56f1eb0d4eb96e14d689d
> 38502af77e07b5d6650b9ff99a0b482d86366592
> c1aad275b0293d2b1905ec95a945422262470684
> f9ca8f74399f9195fd8e01f67a8424a8d33efa55
> 15e5a030716468dce4032fa0f398d840fa2756f6
> 
> 2) Can't create a multiqueue tap
> e8dbad66ef56074eadb41ed5998acd2320447018
> 
> All can be cheery-picked and I have tested them.

Then please work with the network maintainer, as he has a separate
stable queue that he tests and then sends to me, I do not apply stable
patches directly for the network subsystem.

Have you looked at the stable patchwork queue to verify that these are
not in there already?

thanks,

greg k-h

From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 21:36:50 +0200
Message-ID: <201004222136.50397.arnd@arndb.de>
References: <C7F4AD4F.2A34D%scofeldm@cisco.com> <201004222048.53950.arnd@arndb.de> <20100422190230.GL28829@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Mitch Williams <mitch.a.williams@intel.com>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:57618 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757192Ab0DVThH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 15:37:07 -0400
In-Reply-To: <20100422190230.GL28829@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 April 2010 21:02:30 Chris Wright wrote:
> * Arnd Bergmann (arnd@arndb.de) wrote:
> > On Thursday 22 April 2010 19:47:29 Chris Wright wrote:
> > > OK, wasn't clear if you meant that or simply 100% dedicating the interface
> > > via something like virtio.  The add_vf() idea, while neat, doesn't really
> > > match how VF's are allocated.
> > 
> > But we still need something like that for allocating queues in VMDq
> > and similar cases where we do not have pass-through, right?
> 
> Iff we care about VMDq w/out SR-IOV (since SR-IOV hardware is VMDq
> capable and already has a queue-pair + interrupt + net_dev), yes.
> 
> And it's not just VMDq, it's any multi-queue card that can do mac/vlan
> filter in hw + header/data split (for direct data DMA to guest buffers).

Right, that's what I meant by VMDq. Do we have a better term to describe
this class of devices, i.e. VMDq and other cards that also have the
features you listed?

	Arnd

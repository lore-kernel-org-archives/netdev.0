From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Wed, 3 Sep 2014 11:36:05 +0200
Message-ID: <20140903093605.GD4783@worktop.ger.corp.intel.com>
References: <1408683665.5648.69.camel@marge.simpson.net>
 <53F6F14B.1030609@redhat.com>
 <20140822074224.GB7372@gmail.com>
 <53FFEEC0.4000304@redhat.com>
 <540414AB.9000004@linux.intel.com>
 <54053998.4040604@redhat.com>
 <54056076.2030603@linux.intel.com>
 <20140902083124.GB10356@redhat.com>
 <5406B9E6.6050103@linux.intel.com>
 <5406C443.5030109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38908 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755613AbaICJgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:36:09 -0400
Content-Disposition: inline
In-Reply-To: <5406C443.5030109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2014 at 03:33:23PM +0800, Jason Wang wrote:
> A new issue is for virt users. I implement busy polling for virtio-net
> but we don't want one vcpu monopoly the cpu if there's some tasks on
> other vcpus. We may need some hint from host to guest to let it exit the
> loop if needed.

Aw god.. virt nonsense is wrecking things again.

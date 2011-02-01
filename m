From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 13:32:35 -0800
Message-ID: <1296595955.26937.822.camel@localhost.localdomain>
References: <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
	 <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110201212411.GD30770@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-02-01 at 23:24 +0200, Michael S. Tsirkin wrote:
> My theory is that the issue is not signalling.
> Rather, our queue fills up, then host handles
> one packet and sends an interrupt, and we
> immediately wake the queue. So the vq
> once it gets full, stays full.

>From the printk debugging output, it might not be exactly the case. The
ring gets full, run a bit, then gets full, then run a bit, then full...

> If you try my patch with bufs threshold set to e.g.
> half the vq, what we will do is send interrupt after we have processed
> half the vq.  So host has half the vq to go, and guest has half the vq
> to fill.
> 
> See?

I am cleaning up my set up to run your patch ...

Shirley



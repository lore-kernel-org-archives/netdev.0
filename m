From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 14:59:57 -0800
Message-ID: <1296601197.26937.833.camel@localhost.localdomain>
References: <20110127.130240.104065182.davem@davemloft.net>
	 <1296163838.1640.53.camel@localhost.localdomain>
	 <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
	 <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110201215603.GA31348@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-02-01 at 23:56 +0200, Michael S. Tsirkin wrote:
> There are flags for bytes, buffers and packets.
> Try playing with any one of them :)
> Just be sure to use v2.
> 
> 
> >I would like to change it to
> > half of the ring size instead for signaling. Is that OK?
> > 
> > Shirley
> > 
> > 
> 
> Sure that is why I made it a parameter so you can experiment. 

The initial test results shows that the CPUs utilization has been
reduced some, and BW has increased some with the default parameters,
like 1K message size BW goes from 2.5Gb/s about 2.8Gb/s, CPU utilization
down from 4x% to 38%, (Similar results from the patch I submitted a
while ago to reduce signaling on vhost) but far away from dropping
packet results.

I am going to change the code to use 1/2 ring size to wake the netif
queue.

Shirley


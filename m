From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 22:19:09 -0800
Message-ID: <1296627549.26937.856.camel@localhost.localdomain>
References: <20110128121616.GA8374@redhat.com>
	 <OF05820FED.7465B77B-ON8625782A.0001B247-8625782A.00023FA7@us.ibm.com>
	 <1296523838.30191.39.camel@sridhar.beaverton.ibm.com>
	 <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1296626748.26937.852.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-02-01 at 22:05 -0800, Shirley Ma wrote:
> 
> The way I am changing is only when netif queue has stopped, then we
> start to count num_free descriptors to send the signal to wake netif
> queue. 

I forgot to mention, the code change I am making is in guest kernel, in
xmit call back only wake up the queue when it's stopped && num_free >=
1/2 *vq->num, I add a new API in virtio_ring.

However vhost signaling reduction is needed as well. The patch I
submitted a while ago showed both CPUs and BW improvement.

Thanks
Shirley


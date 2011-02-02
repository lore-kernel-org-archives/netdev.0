From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 10:26:09 -0800
Message-ID: <1296671169.25430.50.camel@localhost.localdomain>
References: <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <20110202062950.GD3818@redhat.com>
	 <1296630891.26937.870.camel@localhost.localdomain>
	 <1296632029.26937.871.camel@localhost.localdomain>
	 <20110202104946.GC8505@redhat.com>
	 <1296661371.25430.13.camel@localhost.localdomain>
	 <20110202182024.GA14257@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110202182024.GA14257@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-02 at 20:20 +0200, Michael S. Tsirkin wrote:
> How many packets and bytes per interrupt are sent?
> Also, what about other values for the counters and other counters?
> 
> What does your patch do? Just drop packets instead of
> stopping the interface?
> 
> To have an understanding when should we drop packets
> in the guest, we need to know *why* does it help.
> Otherwise, how do we know it will work for others?
> Note that qdisc will drop packets when it overruns -
> so what is different? Also, are we over-running some other queue
> somewhere? 

Agreed. I am trying to put more debugging output to look for all these
answers.

Shirley


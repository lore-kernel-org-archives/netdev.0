From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 08:38:02 -0800
Message-ID: <1299688682.25664.111.camel@localhost.localdomain>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <1299685543.25664.97.camel@localhost.localdomain>
	 <20110309161013.GA7165@redhat.com>
	 <1299687934.25664.108.camel@localhost.localdomain>
	 <20110309163201.GC7165@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110309163201.GC7165@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-03-09 at 18:32 +0200, Michael S. Tsirkin wrote:
> I think your issues are with TX overrun.
> Besides delaying IRQ on TX, I don't have many ideas.
> 
> The one interesting thing is that you see better speed
> if you drop packets. netdev crowd says this should not happen,
> so could be an indicator of a problem somewhere.

Yes, I am looking at why guest didn't see see used_buffers on time from
vhost send TX completion I am trying to collect some data on vhost.

I also wonder whether it's a scheduler issue.

Thanks
Shirley


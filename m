From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 07:52:34 -0700
Message-ID: <1284562354.2573.12.camel@localhost.localdomain>
References: <20100914152231.GA13105@redhat.com>
	 <1284480025.13351.49.camel@localhost.localdomain>
	 <20100914162952.GB13560@redhat.com>
	 <1284483745.13351.71.camel@localhost.localdomain>
	 <20100914182707.GB15549@redhat.com>
	 <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
	 <1284531675.24603.259.camel@localhost.localdomain>
	 <20100915101000.GB28016@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100915101000.GB28016@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 12:10 +0200, Michael S. Tsirkin wrote:
> Another issue is that macvtap can be bound to almost
> anything, including e.g. a tap device or a bridge,
> which might hang on to skb fragments for unlimited time.
> Zero copy TX won't easily work there.
> I can imagine either somehow triggering a data copy after the
> fact (hard), or detecting such devices and avoiding
> zero copy (unfortunate for guest to guest, and drivers
> will need tuning).

So far macvtap zero copy patch is limited to lower devices supports high
memory DMA, it doesn't apply to a tap device or a bridge.

> >  Don't you think once I address vhost_add_used_and_signal update
> > issue, it is a simple and complete patch for macvtap TX zero copy?
> > 
> > Thanks
> > Shirley
> 
> I like the fact that the patch is simple. Unfortunately
> I suspect it'll stop being simple by the time it's complete :) 

I can make a try. :)

Thanks
Shirley

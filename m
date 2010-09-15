From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 11:48:08 -0700
Message-ID: <1284576488.2573.17.camel@localhost.localdomain>
References: <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
	 <1284531675.24603.259.camel@localhost.localdomain>
	 <20100915101000.GB28016@redhat.com>
	 <1284562354.2573.12.camel@localhost.localdomain>
	 <20100915150412.GA679@redhat.com> <20100915153927.GA1065@redhat.com>
	 <1284570004.2573.14.camel@localhost.localdomain>
	 <20100915173034.GB2612@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100915173034.GB2612@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 19:30 +0200, Michael S. Tsirkin wrote:
> At some level NETIF_F_NETNS_LOCAL makes sense: local packets
> can get anywhere. OTOH one wonders whether there might be other
> issues, e.g. in theory devices could hang on to frag pages
> just by doing get_page.  There might be other issues.
> Maybe we are better off white-listing known-good drivers
> with a new flag? 

Sounds reasonable to me if there is no such a flag to be easily used.

Thanks
Shirley

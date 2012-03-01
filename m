From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Thu, 1 Mar 2012 16:14:14 +0200
Message-ID: <20120301141413.GB4430@redhat.com>
References: <1329225526.2806.34.camel@mojatatu>
 <4F3AAE80.4040609@intel.com>
 <1329315057.4158.15.camel@mojatatu>
 <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
 <1330523779.18226.17.camel@mojatatu>
 <4F4E5FA4.4040506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, chrisw@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	kernel@wantstofly.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F4E5FA4.4040506@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 29, 2012 at 09:25:56AM -0800, John Fastabend wrote:
> Agreed. I think adding some ndo_ops for bridging offloads here would
> work. For example the DSA infrastructure and/or macvlan devices might
> need this. Along the lines of extending this RFC,
> 
> [RFC] hardware bridging support for DSA switches
> http://patchwork.ozlabs.org/patch/16578/
> 
> 
> .John

One place where this might not work well would be
macvtap which is not a network device so it doesn't have
its own address, instead it inherits one from macvlan.

-- 
MST

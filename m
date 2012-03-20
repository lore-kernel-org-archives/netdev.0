From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH v0 0/5] Series short description
Date: Mon, 19 Mar 2012 19:51:47 -0700
Message-ID: <20120319195147.23c26657@nehalam.linuxnetplumber.net>
References: <20120319.183808.976759898435189612.davem@davemloft.net>
	<20120319155537.79d5802c@nehalam.linuxnetplumber.net>
	<4F67CED4.4000700@intel.com>
	<20120319.203541.1126968121556911783.davem@davemloft.net>
	<4F67F04E.8060800@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, gregory.v.rose@intel.com,
	kvm@vger.kernel.org, sri@us.ibm.com, chealy@imsco-us.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F67F04E.8060800@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Mar 2012 19:49:50 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 3/19/2012 5:35 PM, David Miller wrote:
> > From: John Fastabend <john.r.fastabend@intel.com>
> > Date: Mon, 19 Mar 2012 17:27:00 -0700
> > 
> >> Dave, its probably fine to push this to 3.5 then.
> > 
> > Fair enough.
> 
> Stephen, please let me know if you see any issues though
> because without these we have no way to forward packets
> correctly in the embedded switch. So we can't really
> use SR-IOV and virtual interfaces together correctly. And
> the macvlan device in passthru mode is putting the device
> in promiscuous mode which isn't great either.
> 
> .John

I am more worried about evaluating ABI compatibility with older
utilities.

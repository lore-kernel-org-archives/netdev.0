From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Thu, 09 Feb 2012 09:52:55 -0800
Message-ID: <4F3407F7.9000202@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab> <20120208203627.035c6b0e@nehalam.linuxnetplumber.net> <4F34042F.6090806@intel.com> <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/9/2012 9:40 AM, Stephen Hemminger wrote:
> On Thu, 09 Feb 2012 09:36:47 -0800
> John Fastabend <john.r.fastabend@intel.com> wrote:
> 
>> But the device features makes it easy for user space to learn that the device
>> supports this sort of offload. Now if all SR-IOV devices support this then it
>> doesn't matter but I thought there were SR-IOV devices that didn't do any
>> switching? I'll dig through the SR-IOV drivers to check there are not too
>> many of them.
> 
> If user space needs to know then the OS is not designed properly.
> The purpose of the network device is to abstract all those details, and more and more
> of them are bleeding through. This makes writing management applications harder and makes
> things dependent on features that may or may not be present. The best design is when
> the change is invisible.
> 

Agreed.

>> By netlink_notifier do you mean adding a notifier_block and using atomic_notifier_call_chain()
>> probably in rtnl_notify()? Then drivers could register with the notifier chain with
>> atomic_notifier_chain_register() and receive the events correctly. Or did I miss
>> some notifier chain that already exists?
> 
> Yes. that is what I mean. The callbacks you need may or may not already be present.


OK thanks I'll put together an update here shortly.

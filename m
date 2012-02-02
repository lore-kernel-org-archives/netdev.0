From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
 for passthru mode
Date: Thu, 02 Feb 2012 01:04:21 -0800
Message-ID: <4F2A5195.90005@intel.com>
References: <1321575301.2749.51.camel@bwh-desktop> <CAEE6B20.3A9F7%roprabhu@cisco.com> <20120202072448.GA25403@redhat.com> <4F2A4D81.6070002@intel.com> <20120202085037.GA26085@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net, chrisw@redhat.com,
	sri@us.ibm.com, dragos.tatulea@gmail.com, kvm@vger.kernel.org,
	arnd@arndb.de, gregory.v.rose@intel.com, mchan@broadcom.com,
	dwang2@cisco.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	kaber@trash.net, benve@cisco.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120202085037.GA26085@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/2/2012 12:50 AM, Michael S. Tsirkin wrote:
> On Thu, Feb 02, 2012 at 12:46:57AM -0800, John Fastabend wrote:
>> On 2/1/2012 11:24 PM, Michael S. Tsirkin wrote:
>>> On Sun, Nov 20, 2011 at 08:30:24AM -0800, Roopa Prabhu wrote:
>>>>
>>>>
>>>>
>>>> On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
>>>>
>>>>> Sorry to come to this rather late.
>>>>>
>>>>> On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
>>>>> [...]
>>>>>> v2 -> v3
>>>>>> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
>>>>>> - Support for SRIOV VFs.
>>>>>>         [Note: The get filters msg (in the way current get rtnetlink handles
>>>>>>         it) might get too big for SRIOV vfs. This patch follows existing
>>>>>> sriov 
>>>>>>         vf get code and tries to accomodate filters for all VF's in a PF.
>>>>>>         And for the SRIOV case I have only tested the fact that the VF
>>>>>>         arguments are getting delivered to rtnetlink correctly. The code
>>>>>>         follows existing sriov vf handling code so rest of it should work
>>>>>> fine]
>>>>> [...]
>>>>>
>>>>> This is already broken for large numbers of VFs, and increasing the
>>>>> amount of information per VF is going to make the situation worse.  I am
>>>>> no netlink expert but I think that the current approach of bundling all
>>>>> information about an interface in a single message may not be
>>>>> sustainable.
>>>>
>>>> Yes agreed. I have the same concern.
>>>
>>> So it seems that we need to extend the existing interface to allow
>>> tweaking filters per VF. Does it need to block this
>>> patchset though? After all, we'll need to support the existing
>>
>> hmm not sure I follow what patchset is this blocking?
> 
> The one you are replying to.

Gotcha that would seem OK to me although I think you can avoid it altogether.

.John

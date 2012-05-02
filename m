From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next PATCH v4 0/8] Managing the forwarding database(FDB)
Date: Wed, 02 May 2012 16:36:44 -0700
Message-ID: <4FA1C50C.7010405@us.ibm.com>
References: <20120415163905.14091.30491.stgit@jf-dev1-dcblab> <20120415.130637.2258594023349277277.davem@davemloft.net> <20120502150830.GA2976@redhat.com> <4FA1ACA1.2080808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, shemminger@vyatta.com,
	bhutchings@solarflare.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com, roprabhu@cisco.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38316 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab2EBXhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 19:37:06 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Wed, 2 May 2012 17:37:06 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2063DC90050
	for <netdev@vger.kernel.org>; Wed,  2 May 2012 19:36:28 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q42NaUv6088284
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 19:36:30 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4357LYp004260
	for <netdev@vger.kernel.org>; Thu, 3 May 2012 01:07:22 -0400
In-Reply-To: <4FA1ACA1.2080808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 2:52 PM, John Fastabend wrote:
> On 5/2/2012 8:08 AM, Michael S. Tsirkin wrote:
>> On Sun, Apr 15, 2012 at 01:06:37PM -0400, David Miller wrote:
>>> From: John Fastabend<john.r.fastabend@intel.com>
>>> Date: Sun, 15 Apr 2012 09:43:51 -0700
>>>
>>>> The following series is a submission for net-next to allow
>>>> embedded switches and other stacked devices other then the
>>>> Linux bridge to manage a forwarding database.
>>>>
>>>> Previously discussed here,
>>>>
>>>> http://lists.openwall.net/netdev/2012/03/19/26
>>>>
>>>> v4: propagate return codes correctly for ndo_dflt_Fdb_dump()
>>>>
>>>> v3: resolve the macvlan patch 8/8 to fix a dev_set_promiscuity()
>>>>      error and add the flags field to change and get link routines.
>>>>
>>>> v2: addressed feedback from Ben Hutchings resolving a typo in the
>>>>      multicast add/del routines and improving the error handling
>>>>      when both NTF_SELF and NTF_MASTER are set.
>>>>
>>>> I've tested this with 'br' tool published by Stephen Hemminger
>>>> soon to be renamed 'bridge' I believe and various traffic
>>>> generators mostly pktgen, ping, and netperf.
>>> All applied, if we need any more tweaks we can just add them
>>> on top of this work.
>>>
>>> Thanks John.
>> John, do you plan to update kvm userspace to use this interface?
>>
> No immediate plans. I would really appreciate it if you or one
> of the IBM developers working in this space took it on. Of course
> if no one steps up I guess I can eventually get at it but it will
> be sometime. For now I've been doing this manually with the bridge
> tool yet to be published.
>
>
Does this mean that when we add an interface to a bridge, it need not be 
put in promiscuous mode and
add/delete fdb entries dynamically?
Or are we talking only about VMs attached to macvtap?

Thanks
Sridhar

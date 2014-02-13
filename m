From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Thu, 13 Feb 2014 07:50:53 -0500
Message-ID: <52FCBFAD.6000408@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8865.1070302@intel.com> <52FA9074.2060900@mojatatu.com> <52FBC282.6020301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:45672 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbaBMMvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 07:51:04 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so12343964oag.26
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 04:51:04 -0800 (PST)
In-Reply-To: <52FBC282.6020301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/14 13:50, John Fastabend wrote:

>
> Just to wrap things up in one email. Changing between VEB and VEPA
> modes already triggers an event. So management applications can listen
> for this.
>


Ok - reasonable.

> And I can send out a patch to add a flag to hardware bridge devices
> I'll likely get to it next week sometime unless someone beats me
> to it.
>

You understand this better - so i will wait.
I'll send an updated version of the patch this weekend
now that net-next is open.

>
> Sure, IEEE802.1Q would call these edge relays.
>

Ok, so what older kids used to call "repeaters".
The more i think about it, the more it looks like this is
still a bridge and we have a bridgeport mode as VEPA vs VEB.
IOW, as you said - you can have a bridge with mix and match of
VEB/VEPA. We can easily add such a feature to the software bridge
as well. It sounds simple and useful enough.

>
> Because it is not the same type of object as the software bridge.
> Most notably it doesn't do learning. If anything its more like a
> macvlan device and we could just as easily tag it IFF_MACVLAN. So
> because it doesn't really match 1:1 with either of those object I
> would just presume give its own flag. Userspace can always create
> a small macro call it is_bridge_like() and check for any of the
> handful of bridge like objects.
>

I think VEB/VEP may be somehow covering the "port" aspect.
The challenge is what to call "eth0 when running in SRIOV"

>>>
>>> # ip link set dev bridge0 master bridge1
>>> RTNETLINK answers: Too many levels of symbolic links
>>>
>>
>> pourquoi?  If the original rationale was to limit the
>> broadcast domain scope it sounds strange that a bridge in
>> the form a macvlan is allowed.
>>
>
> Agreed. But there it is.
>

I am sure someone knows why - Stephen?

cheers,
jamal

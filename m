From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: Fwd: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Thu, 23 Jan 2014 08:40:36 +0800
Message-ID: <CAEH94LjMpVvNDK7rJa7Jx+HO8VPqtkAi6E=fQ4T0hR0q34bYpg@mail.gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	<52D75EA5.1050000@redhat.com>
	<CAEH94Lg7ygXgHqE8ubE+nuunicDqgmnCfO2AuDSS2nXgv5GikQ@mail.gmail.com>
	<20140116085253.GA32073@stefanha-thinkpad.redhat.com>
	<CA+mtBx9PBtYurdnhCKL0MLL8i+_+3yPNWFVj5h6SPJH+YDBCjw@mail.gmail.com>
	<CAEH94LiqVpXUp3myHvTPVHaqrDpK2V6ii+w8Gip61PA+QF2apw@mail.gmail.com>
	<CA+mtBx-Xv6xp3VCq=PKMyboAmDjUWzVrbUhr4WdKQRi1PCansg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:52759 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbaAWAkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 19:40:37 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so1382387oag.28
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 16:40:36 -0800 (PST)
In-Reply-To: <CA+mtBx-Xv6xp3VCq=PKMyboAmDjUWzVrbUhr4WdKQRi1PCansg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 2:00 AM, Tom Herbert <therbert@google.com> wrote:
>>> 1. The aRFS interface for the guest to specify which virtual queue to
>>> receive a packet on is fairly straight forward.
>>> 2. To hook into RFS, we need to match the virtual queue to the real
>>> CPU it will processed on, and then program the RFS table for that flow
>>> and CPU.
>>> 3. NIC aRFS keys off the RFS tables so it can program the HW with the
>>> correct queue for the CPU.
>> Does anyone have time to make one conclusion for this discussion? in
>> particular, how will rx packet be steered up the stack from guest
>> virtio_net driver, virtio_net NIC, vhost_net, tun driver, host network
>> stack, to physical NIC with more details?
>> What is the role of each path units? otherwise this discussion wont
>> get any meanful result, which is not what we expect.
>>
> Working code outweighs theoretical discussion :-). I think you started
> on a good track with original patches, and I believe the tun path
> should work pretty well (some performance numbers would still be good
I planed to run netperf in one kvm guest with the path "vhost_net +
tun + OVS bridge". But it seems to be a bit difficult for me to get
some x86 hardwares. The boxes which i have all are Power arch.
> to validate). Seems like there's enough hooks in the virtio_net path
> to implement something meaningful and maybe get some numbers (maybe
Can you say what something meaningful is with more details? What is
the roadmap of virt_net aRFS support which you expect?
> ignore NIC aRFS in the first pass).
>
> Tom
>
>>>
>>>> Stefan
>>
>>
>>
>> --
>> Regards,
>>
>> Zhi Yong Wu



-- 
Regards,

Zhi Yong Wu

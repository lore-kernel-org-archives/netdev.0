From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
	virtual functions
Date: Wed, 25 Mar 2009 20:27:28 -0700
Message-ID: <5f2db9d90903252027n7079ca54v76c06ec3849c65d9@mail.gmail.com>
References: <49CAB13B.7070601@intel.com>
	 <20090325.165847.234084422.davem@davemloft.net>
	 <49CAD25F.4080705@intel.com>
	 <20090325.201219.98810772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:7825 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbZCZDdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:33:44 -0400
Received: by yx-out-2324.google.com with SMTP id 31so341317yxl.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 20:33:41 -0700 (PDT)
In-Reply-To: <20090325.201219.98810772.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 8:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 25 Mar 2009 17:54:55 -0700
>
>> Since the issue isn't the igbvf driver there is no reason for it to
>> be held up.
>
> I disagree, I think both cases should be fixed.
>
> Just because we do something already never means that it's
> ok to proliferate the mistake further.

That isn't what I mean.  The code he is referring to exists nowhere in
the igbvf driver.  I suppose I can edit the igbvf commit comments so
that they don't mention the sysfs entry, but the code is in the igb
driver.

Also I just want to clarify.  It isn't fair to compare igbvf to
macvlan.  A better comparison would be virtio since it is meant to run
on a guest, not on the hypervisor/DOM0 OS.  I have also been looking
all over for an example that is even close to what we are looking for
and the sad fact is that the closest thing I can find in the kernel is
the DCB netlink code since it effects the number of queues in use. ,
and I don't have the time to implement anything like that before the
merge window is closed.

What I want to know is if I get rid of the sysfs entry in igb and go
with a static number of VFs, and remove the commit comment referencing
the sysfs entry for igbvf will that be enough to get this accepted for
2.6.30?

Thanks,

Alex

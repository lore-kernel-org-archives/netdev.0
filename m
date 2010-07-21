From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 12:35:36 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F1846287@orsmsx508.amr.corp.intel.com>
References: <20100721.114851.200597269.davem@davemloft.net>
	<20100721.115023.69942880.davem@davemloft.net>
	<43F901BD926A4E43B106BF17856F0755F1846247@orsmsx508.amr.corp.intel.com>
 <20100721.123324.237334251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "leedom@chelsio.com" <leedom@chelsio.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"harald@redhat.com" <harald@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3120 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758916Ab0GUTfq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 15:35:46 -0400
In-Reply-To: <20100721.123324.237334251.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, July 21, 2010 12:33 PM
>To: Rose, Gregory V
>Cc: leedom@chelsio.com; shemminger@vyatta.com; andy@greyhouse.net;
>harald@redhat.com; bhutchings@solarflare.com; sassmann@redhat.com;
>netdev@vger.kernel.org; linux-kernel@vger.kernel.org; gospo@redhat.com;
>Duyck, Alexander H
>Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
>interfaces with random MAC address
>
>From: "Rose, Gregory V" <gregory.v.rose@intel.com>
>Date: Wed, 21 Jul 2010 12:02:17 -0700
>
>>>From: David Miller <davem@davemloft.net>
>>>Date: Wed, 21 Jul 2010 11:48:51 -0700 (PDT)
>>>
>>>> You could do things like have the PF controller use the root
>>>filesystem
>>>> ID label to construct the VF's MAC address, or something like that.
>>>
>>>And here I of course mean the root filesystem of the guest the VF will
>>>be given to.
>>
>> I suppose you could do that but then the VM is going to have to be
>> allowed to set its own MAC address.  There is a lot of opposition
>> and concern about allowing VMs to set their own MAC address.
>
>Why would that be necessary?  The host with the PF creating the guest
>has access to the "device" and thus the root filesystem of the guest,
>and thus could pull in the root filesystem "key" and instantiate the
>VF's MAC before booting the guest.
>
>That was the idea, the control node sets up the VF MAC before the guest
>boots or can have access to the VF device.

I misunderstood you.  My bad.

Thank for the further explanation.

- Greg


From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 11/17] i40e: Add promiscuous on VLAN support
Date: Tue, 20 Oct 2015 18:46:35 +0300
Message-ID: <CAJ3xEMiuRfA=0Kn4DYnow_mftGu4CuqW4AVGTi5CehRiMCkxqA@mail.gmail.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1444715598-20970-12-git-send-email-jeffrey.t.kirsher@intel.com>
	<20151013.041408.880270217805854932.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0789429C4D@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Singhai, Anjali" <anjali.singhai@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36245 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbbJTPqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:46:36 -0400
Received: by igdg1 with SMTP id g1so65918268igd.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 08:46:35 -0700 (PDT)
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0789429C4D@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2015 at 6:31 PM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:

>> > NFV use cases require the ability to steer packets to VSIs by VLAN tag
>> > alone while being in promiscuous mode for multicast and unicast MAC
>> > addresses.  These two new functions support that ability.
>> >
>> > Change-ID: Ifef704b07e0ee8a39d3c351dbd5dc83bb2f63c45
>> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>> > Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> The patch(es) that use these functions are not yet prepared.  We will wait until they're ready to submit these patches.  Sorry for the confusion but I was out on vacation and didn't have a chance to coordinate this with Jeff.

> We needed the VF trust code in the kernel before we could add in these additional patches.  We can work with Anjali to get those now that the VF trust feature is in the kernel.

Can you please explain your design for supporting VF promiscuous mode?

Or.

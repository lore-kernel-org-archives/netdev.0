From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 06/13] i40e: implement anti-spoofing for VFs
Date: Wed, 11 Jun 2014 15:43:01 +0300
Message-ID: <CAJZOPZLr-QYMfQ6homSvkDfUh+np3q5qbmRNLzBgxyWjk+LONQ@mail.gmail.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1402303758-1429-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZJGZNhX7yPF6MvCjW+EYi-EGJgW1GhFa5CO=myAgJj-1A@mail.gmail.com>
	<1402488782.2306.18.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:55064 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbaFKMnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 08:43:03 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so4104413qac.36
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 05:43:01 -0700 (PDT)
In-Reply-To: <1402488782.2306.18.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 3:13 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Mon, 2014-06-09 at 22:49 +0300, Or Gerlitz wrote:
>> On Mon, Jun 9, 2014 at 11:49 AM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Mitch Williams <mitch.a.williams@intel.com>
>> >
>> > Our hardware supports VF antispoofing for both MAC addresses and VLANs.
>> > Enable this feature by default for all VFs
>>
>> What do you expect the HW to do when spoof check is enabled (by
>> default) but the admin didn't configure a MAC address for the VF
>> through the PF? that is the VF is allowed to use what ever MAC they
>> want to?
>>
>> > and implement the netdev op to control it from the command line.
>
> Here is the answer I got:
> If the VF mac address is set within the VM and it is accepted by the PF,

When the admin doesn't configure MAC address for the VM, what logic is
applied by the PF to decide whether or not to accept a VF MAC set by the VM?

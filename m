From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 13:53:14 +0200
Message-ID: <20130722115314.GB1552@minipsycho.orion>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
 <1374342834-10814-2-git-send-email-jiri@resnulli.us>
 <CAJZOPZJiL4hJV4eKKsZrLseJF_sSRjYVsstgT+NLsoeCXWKh_g@mail.gmail.com>
 <20130721210230.GA1558@minipsycho.orion>
 <20130722112921.GA4511@fedora18-dev.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: or.gerlitz@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:33869 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab3GVLxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 07:53:19 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so3745477eek.22
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 04:53:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130722112921.GA4511@fedora18-dev.oslab.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 22, 2013 at 01:29:50PM CEST, Narendra_K@Dell.com wrote:
>On Mon, Jul 22, 2013 at 02:32:30AM +0530, Jiri Pirko wrote:
>> 
>> Sun, Jul 21, 2013 at 10:26:32PM CEST, or.gerlitz@gmail.com wrote:
>> >On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >>
>> >> This patch adds a ndo for getting physical port of the device. Driver
>> >> which is aware of being virtual function of some physical port should
>> >> implement this ndo.
>> >
>> >
>> >Do you mean virtual function literally?  that is in the PCI IOV aspect?
>> 
>> This is applicable not only for IOV, nbut for other solutions (NPAR,
>> multichannel) as well. Basically if there is possible to have multiple
>> netdevs on the single hw port.
>
>I think it would be useful to include this information in the commit
>message.

ok. I will resend the patchset soon.

>
>-- 
>With regards,
>Narendra K
>Linux Engineering
>Dell Inc.

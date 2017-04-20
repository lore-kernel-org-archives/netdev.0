From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 11:51:53 -0400 (EDT)
Message-ID: <20170420.115153.1510206006505486594.davem@davemloft.net>
References: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420113942.GD1886@nanopsycho.orion>
        <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gerlitz.or@gmail.com,
        jeffrey.t.kirsher@intel.com, mitch.a.williams@intel.com,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970689AbdDTPvz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:51:55 -0400
In-Reply-To: <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 20 Apr 2017 13:57:08 +0000

> I agree this surely isn't *our* convention, but for scsi  using debugfs
> [or sysfs] is a common practice for debug purposes.
> 
> Also, our HW debug capabilities are highly-customable, and I want to
> have the ability to configure those on the fly [E.g., dynamically
> configuring various HW events to be recorded].
> Each such configuration involves multiple register writes and reads
> according to user provided inputs.
> I don't really see how to generalize the information collection in a way
> that would benefit anyone else.

That's basically what everyone says who slaps random crap into debugfs.

>> For your inhouse debugging, you should have oot
>> patch to expose whatever you need.
> 
> I don't want in-house debugging capabilities -
> I want field debug capabilities.

Then it has to use a portable, well defined, set of interfaces.

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/2] virtio_net: add ethtool get/set settings
 support
Date: Sun, 7 Feb 2016 20:35:28 +0100
Message-ID: <56B79C80.2070508@cumulusnetworks.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <20160207.143117.2074335859138369633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34880 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbcBGTfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:35:31 -0500
Received: by mail-wm0-f53.google.com with SMTP id r129so88672436wmr.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 11:35:30 -0800 (PST)
In-Reply-To: <20160207.143117.2074335859138369633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2016 08:31 PM, David Miller wrote:
> From: Nikolay Aleksandrov <razor@blackwall.org>
> Date: Wed,  3 Feb 2016 04:04:35 +0100
> 
>> Patch 1 adds ethtool speed/duplex validation functions which check if the
>> value is defined. Patch 2 adds support for ethtool (get|set)_settings and
>> uses the validation functions to check the user-supplied values.
>>
>> v2: split in 2 patches to allow everyone to make use of the validation
>> functions and allow virtio_net devices to be half duplex
>> v3: added a check to return error if the user tries to change anything else
>> besides duplex/speed as per Michael's comment
>> v4: Set port type to PORT_OTHER
>> v5: clear diff1.port (ignore port) when checking for changes since we set
>> it now and ethtool uses it in the set request
>>
>> Sorry about the pointless iterations, should've all covered now.
> 
> Series applied, thanks Nik.
> 

Thank you Dave, I was actually waiting for Michael's ethtool patch to go in.
I'll send a follow-up to make sure the port is what we set it to and also
to allow setting any speed (as people commented, devices can have any speed
these days, so we don't want to limit them to the defined ones).

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 13:21:10 +0100
Message-ID: <20160223122109.GD2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35960 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcBWMVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 07:21:13 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so219228313wme.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 04:21:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CC41C8.10802@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 12:26:00PM CET, hannes@stressinduktion.org wrote:
>Hi Jiri,
>
>On 22.02.2016 19:31, Jiri Pirko wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>So far, there has been an mlx4-specific sysfs file allowing user to
>>change port type to either Ethernet of InfiniBand. This is very
>>inconvenient.
>
>Again, I want to express my concerns regarding all of this until this will be
>integrated into udev/systemd for stable device names. While one can build
>wrapper code around devlink to have stable devlink ports, I don't see a
>reason to include kernel code which actually has more problems than the sysfs
>approach. This harms admins to use those devices and will additionally
>require user space to write boiler plate code.

Sysfs is not the place to do this things. It was already discussed here
multiple times. There was and attempt to use configfs, which was also
refused. Netlink is the only place to go. For multiple reasons,
including well defined api and behaviour, notifications, etc.

I think it is quite trivial to teach udev to name devlinkX devices
according to pci address (or any other address). That's all what is
needed here. I don't understand your concerns.

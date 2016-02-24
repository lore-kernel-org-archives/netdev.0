From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Wed, 24 Feb 2016 08:15:27 +0100
Message-ID: <20160224071527.GA2151@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org>
 <20160223093139.21303e16@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37077 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbcBXHPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 02:15:30 -0500
Received: by mail-wm0-f42.google.com with SMTP id g62so16203944wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 23:15:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223093139.21303e16@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 06:31:39PM CET, stephen@networkplumber.org wrote:
>On Tue, 23 Feb 2016 12:26:00 +0100
>Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>
>> Hi Jiri,
>> 
>> On 22.02.2016 19:31, Jiri Pirko wrote:
>> > From: Jiri Pirko <jiri@mellanox.com>
>> >
>> > So far, there has been an mlx4-specific sysfs file allowing user to
>> > change port type to either Ethernet of InfiniBand. This is very
>> > inconvenient.
>> 
>> Again, I want to express my concerns regarding all of this until this 
>> will be integrated into udev/systemd for stable device names. While one 
>> can build wrapper code around devlink to have stable devlink ports, I 
>> don't see a reason to include kernel code which actually has more 
>> problems than the sysfs approach. This harms admins to use those devices 
>> and will additionally require user space to write boiler plate code.
>> 
>> Thanks,
>> Hannes
>> 
>
>I appreciate that you need to have a lighterweight model for
>network devices. But have to agree with Hannes.

No, I don't need to have lighterweight model for network device. This
patch does nothing like that.


>
>This code breaks the model expected by applications like Quagga, SNMP
>and lots of other legacy code. Is this really going to work with the
>legacy Linux model.

No, this patch does not break anything. The original netdev still stay.

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 12:26:00 +0100
Message-ID: <56CC41C8.10802@stressinduktion.org>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52890 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbcBWL0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 06:26:08 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 19BFB20A8C
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:26:08 -0500 (EST)
In-Reply-To: <1456165924-14399-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On 22.02.2016 19:31, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> So far, there has been an mlx4-specific sysfs file allowing user to
> change port type to either Ethernet of InfiniBand. This is very
> inconvenient.

Again, I want to express my concerns regarding all of this until this 
will be integrated into udev/systemd for stable device names. While one 
can build wrapper code around devlink to have stable devlink ports, I 
don't see a reason to include kernel code which actually has more 
problems than the sysfs approach. This harms admins to use those devices 
and will additionally require user space to write boiler plate code.

Thanks,
Hannes

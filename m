From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] netdev: driver: ethernet: add sysfs interface for ti
 cpsw
Date: Tue, 03 Jul 2012 16:38:08 -0700
Message-ID: <4FF38260.2040702@intel.com>
References: <1341345086-25093-1-git-send-email-s-paulraj@ti.com> <20120703.161623.1843927245895613219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cyril@ti.com,
	mugunthanvnm@ti.com, netdev@vger.kernel.org
To: s-paulraj@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54298 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab2GCXiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 19:38:09 -0400
In-Reply-To: <20120703.161623.1843927245895613219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2012 4:16 PM, David Miller wrote:
> From: <s-paulraj@ti.com>
> Date: Tue, 3 Jul 2012 15:51:26 -0400
>
>> From: Sandeep Paulraj <s-paulraj@ti.com>
>>
>> This patch adds sysfs entries for address lookup engine entries and
>> control for the ALE(address lookup engine) found in TI SOC's.
>>
>>
>> Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>
>
> You may not create private, driver specific, unique interfaces to
> configure your hardware.
>
> You must use existing facilities such as ethtool to add such things.
> If the existing facilities are insufficient, you must extend them to
> meet your (and potentially other's) needs.
> --

I can't seem to dig up the original email perhaps my server is slow
today but did you consider using these hooks ndo_fdb_add(),
ndo_fdb_del(), and ndo_fdb_dump() added recently.

These are for adding/deleting and dumping the address forwarding
databases. Failing that would something like this RFC with another
attribute work,

http://comments.gmane.org/gmane.linux.network/232104

Thanks,
John

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Wed, 3 Feb 2016 14:33:56 +0100
Message-ID: <20160203133356.GA2219@nanopsycho.orion>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36318 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbcBCNd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 08:33:59 -0500
Received: by mail-wm0-f49.google.com with SMTP id p63so165381538wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 05:33:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160203143133.1b70bcb5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 03, 2016 at 02:31:33PM CET, brouer@redhat.com wrote:
>On Wed,  3 Feb 2016 11:47:56 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> There a is need for some userspace API that would allow to expose things
>> that are not directly related to any device class like net_device of
>> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
>> 
>> Use cases:
>> 1) get/set of port type (Ethernet/InfiniBand)
>> 2) monitoring of hardware messages to and from chip
>> 3) setting up port splitters - split port into multiple ones and squash again,
>>    enables usage of splitter cable
>> 4) setting up shared buffers - shared among multiple ports within one chip
>> 
>> First patch of this set introduces a new generic Netlink based interface,
>> called "devlink". It is similar to nl80211 model and it is heavily
>> influenced by it, including the API definition. The devlink introduction patch
>> implements use cases 1) and 2). Other 2 are in development atm and will
>> be addressed by follow-ups.
>> 
>> It is very convenient for drivers to use devlink, as you can see in other
>> patches in this set.
>> 
>> Counterpart for devlink is userspace tool called "dl". Command line interface
>> and outputs are derived from "ip" tool so it should be easy for users to get
>> used to it.
>> 
>> It is available here:
>> https://github.com/jpirko/devlink
>
>IHMO this very short command name "dl" is not an advantage.  It is
>simply too unspecific and short for a good Google search.  E.g. when
>searching for good examples for using "dl".  I think "devlink" would be
>better.  If you like short commands do: alias dl="devlink"

I was thinking about using "devlink". Decided to go with shortened
version so this is in-line with "ip". But you have a point.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate
 modules
Date: Tue, 28 Oct 2014 00:48:48 -0400 (EDT)
Message-ID: <20141028.004848.2155168949974328949.davem@davemloft.net>
References: <CALnjE+opCLA9KJ5RHaUs1vbx41p6=iUi9B59Q7G0TeSTmWm7_w@mail.gmail.com>
	<20141027214722.GA2783@casper.infradead.org>
	<CALnjE+p5b5EzLkY6_6J7jvwyf9rUdu-JGbdf5r3bDuhgndoeeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dev@openvswitch.org, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188AbaJ1Esx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 00:48:53 -0400
In-Reply-To: <CALnjE+p5b5EzLkY6_6J7jvwyf9rUdu-JGbdf5r3bDuhgndoeeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Mon, 27 Oct 2014 17:27:11 -0700

> On Mon, Oct 27, 2014 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> The patch also brings additional flexibility to users of
>> distributions. Distros typically ship something like an allmodconfig
>> so a user can either run openvswitch.ko with all encaps compiled in
>> or not run openvswitch.ko. With vports as module, a user can blacklist
>> a certain encap type.
>>
>> Another advantage is obviously that users can run additional vport
>> types on top of their distribution kernels.
>>
>> Is there anything specific that you are concerned with in regard
>> to this proposed change?
> 
> OVS vport code is not alot and making it plugable module does not save
> much space.

People don't blacklist modules to "save space".

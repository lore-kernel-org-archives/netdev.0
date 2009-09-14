From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH 4/4] bonding: add sysfs files to display
 tlb and alb	hash table contents
Date: Mon, 14 Sep 2009 21:37:33 +0200
Message-ID: <4AAE9B7D.7030608@free.fr>
References: <20090911211317.GT8515@gospo.rdu.redhat.com>	<26430.1252705697@death.nxdomain.ibm.com> <20090914144532.GU8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:33688 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756806AbZINThk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 15:37:40 -0400
In-Reply-To: <20090914144532.GU8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> On Fri, Sep 11, 2009 at 02:48:17PM -0700, Jay Vosburgh wrote:
>> Andy Gospodarek <andy@greyhouse.net> wrote:
>>
>>> bonding: add sysfs files to display tlb and alb hash table contents
>> 	Isn't it considered bad form to have sysfs files that kick out
>> large amounts of data like this?  Not that I think this is a bad
>> facility to have, just checking on the mechanism.
>>
> 
> I'm not aware of such a restriction -- though I'm sure at least one
> person out there doesn't like it.

In Documentation/filesystems/sysfs.txt:

"Attributes should be ASCII text files, preferably with only one value
per file. It is noted that it may not be efficient to contain only one
value per file, so it is socially acceptable to express an array of
values of the same type.

Mixing types, expressing multiple lines of data, and doing fancy
formatting of data is heavily frowned upon. Doing these things may get
you publically humiliated and your code rewritten without notice."

Apparently, thinks are becoming more relaxed these days.

	Nicolas.

> If that's the case, there are certainly a few files that should be
> cleaned up:
> 
> # find -type f -exec wc -l {} 2> /dev/null \; | sort -r -n | head -10
> 1657 ./firmware/acpi/tables/SSDT
> 132 ./firmware/acpi/tables/dynamic/SSDT2
> 128 ./devices/pci0000:00/0000:00:1c.5/0000:3f:00.0/vpd
> 27 ./devices/system/node/node0/meminfo
> 24 ./devices/pnp0/00:08/options
> 24 ./devices/pnp0/00:07/options
> 12 ./devices/pci0000:00/0000:00:1e.0/resource
> 12 ./devices/pci0000:00/0000:00:1c.5/resource
> 12 ./devices/pci0000:00/0000:00:1c.4/resource
> 12 ./devices/pci0000:00/0000:00:1c.0/resource


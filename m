From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 3/3] ixgbe: add syfs interface for to export read
 only driver information
Date: Thu, 5 Apr 2012 23:01:32 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866460F58D4FE@FMSMSX151.amr.corp.intel.com>
References: <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<4F7D8DD4.5080205@openwrt.org>
	<1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
 <20120405.184935.422690748002137749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "florian@openwrt.org" <florian@openwrt.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57240 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2DEXBx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:01:53 -0400
In-Reply-To: <20120405.184935.422690748002137749.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, April 05, 2012 3:50 PM
>To: bhutchings@solarflare.com
>Cc: florian@openwrt.org; Kirsher, Jeffrey T; Skidmore, Donald C;
>netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export re=
ad
>only driver information
>
>From: Ben Hutchings <bhutchings@solarflare.com>
>Date: Thu, 5 Apr 2012 17:32:05 +0100
>
>> On Thu, 2012-04-05 at 14:19 +0200, Florian Fainelli wrote:
>>> Hi,
>>>
>>> Le 04/05/12 12:47, Jeff Kirsher a =E9crit :
>>> > From: Don Skidmore<donald.c.skidmore@intel.com>
>>> >
>>> > This patch exports non-thermal (which was done via hwmon in an
>earlier
>>> > patch) data to syfs.  All of the fields are read only as this
>interface
>>> > is to only export driver data.
>>> >
>>> > Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
>>> > Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> > ---
>>>
>>> I only looked briefly at the exported attributes, but most of them
>can
>>> already be queried using ethtool, can't they?
>> [...]
>>
>> I agree, it looks like most of these are:
>>
>> (1) already exposed through ethtool commands (ETHTOOL_GSET,
>> ETHTOOL_GDRVINFO, ETHTOOL_GLINK and ETHTOOL_GPERMADDR), or
>> (2) already exposed through rtnetlink or the net device in sysfs, or
>> (3) statistics that should be exposed through ETHTOOL_GSTATS
>>
>> I imagine there are some that don't fall into those categories, but =
I
>> don't see why they should *all* be exposed in a non-standard and/or
>> redundant way.
>
>Agreed.

Thanks for the input.  I'll start on refactoring the patch to exclude a=
ll items that are exposed in any other way.

-Don Skidmore <donald.c.skidmore@intel.com>

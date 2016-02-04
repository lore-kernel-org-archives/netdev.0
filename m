From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Thu, 4 Feb 2016 09:30:14 -0800
Message-ID: <56B38AA6.9050307@hpe.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-2-git-send-email-razor@blackwall.org>
 <20160204103226.333d98ca@samsung9> <56B291F0.9010909@hpe.com>
 <20160204142327-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	linux-api@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:47938 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965246AbcBDRaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 12:30:18 -0500
In-Reply-To: <20160204142327-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 04:47 AM, Michael S. Tsirkin wrote:
> On Wed, Feb 03, 2016 at 03:49:04PM -0800, Rick Jones wrote:
>> And even for not-quite-virtual devices - such as a VC/FlexNIC in an HPE
>> blade server there can be just about any speed set.  I think we went down a
>> path of patching some things to address that many years ago.  It would be a
>> shame to undo that.
>>
>> rick
>
> I'm not sure I understand. The question is in defining the UAPI.
> We currently have:
>
>   * @speed: Low bits of the speed
>   * @speed_hi: Hi bits of the speed
>
> with the assumption that all values come from the defines.
>
> So if we allow any value here we need to define what it means.

I may be mixing apples and kiwis.  Many years ago when HP came-out with 
their blades and VirtualConnect, they included the ability to create 
"flex NICs" - "sub-NICs" out of a given interface port on a blade, and 
to assign each a specific bitrate in increments (IIRC) of 100 Mbit/s. 
This was reported up through the driver and it became necessary to make 
ethtool (again, IIRC) not so picky about "valid" speed values.

rick

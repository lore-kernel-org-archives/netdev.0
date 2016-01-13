From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 13 Jan 2016 00:59:00 +0000
Message-ID: <3EF5B56E-FA0D-4A4F-A6C6-DE306FA1E610@intel.com>
References: <20160106.163309.111867454969344145.davem@davemloft.net>,<20160113004916.GA28880@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38436 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbcAMA7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 19:59:02 -0500
In-Reply-To: <20160113004916.GA28880@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jan 12, 2016, at 16:49, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:
> 
>> On (01/06/16 16:33), David Miller wrote:
>> 
>> A repeating pattern in drivers has become to use OF node information
>> and, if not found, platform specific host information to extract the
>> ethernet address for a given device.
>    :
>> Consolidate this into a portable routine, and provide the
>> arch_get_platform_mac_address() weak function hook for all
>> architectures to implement if they want.
>    :
>> As promised back in November, I'm commiting this into net-next
>> now.  I'd work on the conversions of existing drivers, but I'd
>> rather someone with access to the hardware to so.
> 
> I finally have all the ducks lined up for ixgbe/i40e around this. 
> Should I go ahead and send this off (I think it first gets staged 
> through Jeff's repo?) or is it better to wait for net-next to be 
> open again?

please go ahead and send it to intel-wired-lan@lists.osuosl.org so we can review and test the driver parts so when net-next opens it should be ready to push upstream.

From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Tue, 14 Jun 2011 13:19:08 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016C7DEB5B@orsmsx508.amr.corp.intel.com>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
 <20110614185153.GC12002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45925 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529Ab1FNUTJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 16:19:09 -0400
In-Reply-To: <20110614185153.GC12002@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Tuesday, June 14, 2011 11:52 AM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org
>Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
>config to ethtool.
>
>Carolyn Wyborny wrote:
>> This RFC patch adds functions to get and set DMA Coalescing feature
>> configuration.
>>
>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> ---
>>  include/linux/ethtool.h |   15 ++++++++++++++-
>>  net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
>>  2 files changed, 46 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index c6a850a..efed754 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -703,6 +703,14 @@ enum ethtool_sfeatures_retval_bits {
>>  	ETHTOOL_F_COMPAT__BIT,
>>  };
>>
>> +/* for configuring DMA coalescing parameters of chip */
>> +struct ethtool_dmac {
>> +	__u32	cmd;	/* ETHTOOL_{G,S}DMAC */
>> +
>> +	/* tune setting, options and validation determined by device. */
>> +	__u32	tune;
>> +};
>[...]
>
>I don't think we should be adding operations that have no generic
>semantics at all.  Further, we will not add any operations without at
>least one implementation as an example.
>
>Secondly, ethtool operations that only get/set a 32-bit value should
>use struct ethtool_value for the parameter.
>
>Ben.
>
>--
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.

Ok, will send up update with the suggested changes and an implementation as an example.  I have one, but will wait to synch it with the updated patch.  Do you want another RFC or a regular patch submission?

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



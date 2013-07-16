From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/3] net: add ndo to get id of physical port
 of the device
Date: Tue, 16 Jul 2013 08:41:09 +0200
Message-ID: <20130716064109.GA1600@minipsycho.orion>
References: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
 <1373908027-25800-2-git-send-email-jiri@resnulli.us>
 <1373925717.3745.24.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Narendra_K@Dell.com,
	john.r.fastabend@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:35473 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab3GPGlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 02:41:13 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so138462eek.31
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 23:41:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1373925717.3745.24.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 16, 2013 at 12:01:57AM CEST, bhutchings@solarflare.com wrote:
>On Mon, 2013-07-15 at 19:07 +0200, Jiri Pirko wrote:
>> This patch adds a ndo for getting physical port of the device. Driver
>> which is aware of being virtual function of some physical port should
>> implement this ndo.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/netdevice.h | 18 ++++++++++++++++++
>>  1 file changed, 18 insertions(+)
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 0741a1e..e85f177 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
>>  };
>>  #endif
>>  
>> +#define MAX_PHYS_PORT_ID_LEN 32
>> +
>> +/* This structure holds a universally unique identifier to
>> + * identify the physical port used by a netdevice
>[...]
>
>There is a slight problem with saying 'universally unique identifier'
>which is that it may be taken to mean specifically a DCE 128-bit UUID.
>Is there a slightly more generic term that would clearly allow for other
>ID spaces here?  Or should we give a list of examples: 'such as a
>128-bit UUID, globally unique MAC-48 or EUI-64'?

Well I do not have any speficic format in mind. I think that whatever
hash (driver's choice) would do. I will reword the comment.

Thanks Ben.

Jiri

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>

From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [libvirt] if_bridge.h: include in6.h for struct in6_addr use
Date: Wed, 13 Mar 2013 10:17:40 -0500
Message-ID: <81B30F90-5A18-4386-9C30-E336AE212D85@kernel.crashing.org>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org> <50F49B7E.50906@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Thomas Backlund <tmb@mageia.org>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org list" <linux-kernel@vger.kernel.org>,
	libvirt-list@redhat.com, stephen@networkplumber.org,
	Zhenhua Luo <zhenhua.luo@freescale.com>
To: Eric Blake <eblake@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40306 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab3CMPR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 11:17:57 -0400
In-Reply-To: <50F49B7E.50906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 14, 2013, at 5:57 PM, Eric Blake wrote:

> On 01/13/2013 01:05 PM, Thomas Backlund wrote:
>> Thomas Backlund skrev 13.1.2013 20:38:
>>> patch both inline and attached as thunderbird tends to mess up ...
>> 
>>> -----
>>> 
>>> if_bridge.h uses struct in6_addr ip6; but does not include the in6.h
>>> header.
>>> 
>>> Found by trying to build libvirt and connman against 3.8-rc3 headers.
>>> 
>> 
>> Ok,
>> ignore this patch, it's not the correct fix as it introduces
>> redefinitions...
>> 
>> Btw, the error that I hit that made me suggest this fix was libvirt
>> config check bailing out:
>> 
>> config.log:/usr/include/linux/if_bridge.h:173:20: error: field 'ip6' has
>> incomplete type
> 
> Hmm, just now noticing this thread, after independently hitting and and
> having to work around the same problem in libvirt:
> https://www.redhat.com/archives/libvir-list/2013-January/msg00930.html
> https://bugzilla.redhat.com/show_bug.cgi?id=895141
> 
>>> --- linux-3.8-rc3/include/uapi/linux/if_bridge.h        2013-01-13
>>> 20:09:54.257271755 +0200
>>> +++ linux-3.8-rc3.fix/include/uapi/linux/if_bridge.h    2013-01-13
>>> 20:15:04.153676151 +0200
>>> @@ -14,6 +14,7 @@
>>>  #define _UAPI_LINUX_IF_BRIDGE_H
>>> 
>>>  #include <linux/types.h>
>>> +#include <linux/in6.h>
>>> 

Did this ever get resolved ?

- k

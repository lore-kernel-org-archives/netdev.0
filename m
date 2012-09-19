From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Netfilter lacks ability to filter packets via Application-origin
Date: Wed, 19 Sep 2012 13:50:39 -0700
Message-ID: <505A301F.5040201@intel.com>
References: <COL002-W12C33BCBEB56AC8ADFF6B0F39B0@phx.gbl> <1348086252.2636.58.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chad Gray <chad938@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21711 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787Ab2ISUul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 16:50:41 -0400
In-Reply-To: <1348086252.2636.58.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/19/2012 1:24 PM, Ben Hutchings wrote:
> On Wed, 2012-09-19 at 15:40 -0400, Chad Gray wrote:
>> Users need the ability for Linux firewall to filter packets based on what
>> Application they are originating from. This ability is present in Mac and
>> Windows firewalls, but not Linux.
>>
>> For example, users would like ability to open Port 80 for Firefox, but keep
>> Port 80 closed for other applications.
>>
>> This ability enhances Privacy & Security of the user but also helps to better
>> inform the user about the comings and goings of internet traffic and what
>> application/s are causing the traffic.
>
> Most of the Linux Security Modules seem to support this sort of network
> policy.
>
> Ben.
>

Another approach might be to use the net_cls cgroups and set the
classid matching against it with tc or netfilters.

.John

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] netfilter: remove deprecated config option
 NF_CT_ACCT
Date: Wed, 30 Jun 2010 15:42:17 +0200
Message-ID: <4C2B49B9.5050302@trash.net>
References: <20100629154507.GA5260@psychotron.brq.redhat.com> <4C2B3437.6000602@trash.net> <20100630124954.GA2582@psychotron.brq.redhat.com> <4C2B3E3D.7030804@trash.net> <20100630131153.GB2582@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ole@ans.pl
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38464 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab0F3NmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 09:42:18 -0400
In-Reply-To: <20100630131153.GB2582@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Wed, Jun 30, 2010 at 02:53:17PM CEST, kaber@trash.net wrote:
>   
>> Jiri Pirko wrote:
>>     
>>> Apart your patch doesn't remove option from defconfigs (not sure if that's
>>> necessary or not), your patch also do not print warning in connbytes_mt_init.
>>> That would make connbytes silently non-functional. Therefore I think my patch is
>>> better (more complete).
>>>       
>> The patch I have queued is automatically enabling accounting when
>> the connbytes match is used and is printing a warning.
>>     
>
> ok, that looks fine to me. What about those config options in def_config files?
>   

I usually leave those for the architecture maintainers.


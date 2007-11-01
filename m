From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Clean the ip_sockglue.c from some ugly ifdefs
Date: Thu, 01 Nov 2007 19:38:24 +0300
Message-ID: <472A0100.2030506@openvz.org>
References: <4729F642.7000709@openvz.org> <20071101163112.GE13130@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60686 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbXKAQie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 12:38:34 -0400
In-Reply-To: <20071101163112.GE13130@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Thu, Nov 01, 2007 at 06:52:34PM +0300, Pavel Emelyanov escreveu:
>> The #idfed CONFIG_IP_MROUTE is sometimes places inside the if-s,
>> which looks completely bad. Similar ifdefs inside the functions
>> looks a bit better, but they are also not recommended to be used.
>>
>> Provide an ifdef-ed ip_mroute_opt() helper to cleanup the code.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Perhaps a better name would be ip_mroute_valid_opt()?

No :) The _valid_ mrote opts are from 0 to 8, according to MRT_XXX
macros, not from 0 to 10 as checked. I suspect this was a kind of 
reserve for future use and thus do not change this. 

Correct me if I am wrong.

> - Arnaldo

Thanks,
Pavel

From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH net-next v2] net: Initialize table in fib result
Date: Thu, 17 Sep 2015 09:45:16 +0200
Message-ID: <55FA6F8C.90808@ericsson.com>
References: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com> <55F996AC.1090305@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	<sergey.senozhatsky.work@gmail.com>, <festevam@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:42486 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbIQHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 03:45:29 -0400
In-Reply-To: <55F996AC.1090305@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-09-16 18:19, Nikolay Aleksandrov wrote:
> The root cause is use of res.table uninitialized.
>> 
>> Thanks to Nikolay for noticing the uninitialized use amongst the maze of
>> gotos.
>> 
>> As Nikolay pointed out the second initialization is not required to fix
>> the oops, but rather to fix a related problem where a valid lookup should
>> be invalidated before creating the rth entry.
>> 
>> Fixes: b7503e0cdb5d ("net: Add FIB table id to rtable")
>> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
>> Reported-by: Richard Alpe <richard.alpe@ericsson.com>
Works for me as well. Thanks!

(Tested-by: Richard Alpe <richard.alpe@ericsson.com>)

Regards
Richard

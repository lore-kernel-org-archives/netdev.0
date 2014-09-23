From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Tue, 23 Sep 2014 13:12:47 +0200
Message-ID: <542155AF.4020805@ericsson.com>
References: <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>	<20140912.171038.1165432718811920305.davem@davemloft.net>	<54169B6C.5060709@ericsson.com> <20140915.113846.1276168899072885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:54337 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbaIWLN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 07:13:57 -0400
In-Reply-To: <20140915.113846.1276168899072885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 05:38 PM, David Miller wrote:
> From: Richard Alpe <richard.alpe@ericsson.com>
> Date: Mon, 15 Sep 2014 09:55:24 +0200
>
>> The amount of publications a socket can have is large (~65 000). Do
>> you still think this a viable solution?
>
> Then maybe you want to have a completely separate netlink operation to
> dump the publications, the request would provide a key saying which
> socket's publications to dump.
Yes, that would be a nice thing to have.

Ideally I would like to use the existing dump framework .dumpit 
(netlink_dump_start()) but I can't figure out a way to pass the socket 
for which to dump publications. I really don't want to reinvent the 
dumping mechanism. Any suggestions?

Regards
Richard

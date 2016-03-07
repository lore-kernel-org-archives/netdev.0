From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH v2 06/20] iproute: TYPE keyword is not optional,
 fix help text accordingly
Date: Mon, 7 Mar 2016 06:23:42 -0500
Message-ID: <56DD64BE.9080005@mojatatu.com>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
 <1456942808-15946-7-git-send-email-phil@nwl.cc>
 <56D84883.3080902@mojatatu.com> <20160303150557.GE18624@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33323 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbcCGLXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 06:23:44 -0500
Received: by mail-io0-f194.google.com with SMTP id g203so10704118iof.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 03:23:44 -0800 (PST)
In-Reply-To: <20160303150557.GE18624@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-03 10:05 AM, Phil Sutter wrote:
> On Thu, Mar 03, 2016 at 09:21:55AM -0500, Jamal Hadi Salim wrote:
>> On 16-03-02 01:19 PM, Phil Sutter wrote:
>>> +	fprintf(stderr, "          unreachable | prohibit | blackhole | nat }\n");
>>
>> Dont think nat exists anymore...
>
> But iproute2 seems to still support it? At least it's listed in
> rtnl_rtntype_a2n().
>
> The entry for RTN_NAT in net/ipv4/fib_semantics.c though looks like just
> a stub. But at least it hasn't changed since the beginning of Git.
> According to ip-route.8 it's indeed non-functional.
>
> I only concerned help text and man page consistency, and since the man
> page lists it (with a useful hint about it's state), the help text
> should contain it either. Or do you think that's misleading?
>

Yeah it is gone. The cloud providers i know of that needed stateless
nat use tc nat.

cheers,
jamal

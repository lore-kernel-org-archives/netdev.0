From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Make table id type u32
Date: Tue, 1 Sep 2015 12:39:54 -0600
Message-ID: <55E5F0FA.4080909@cumulusnetworks.com>
References: <1441131487-29367-1-git-send-email-dsa@cumulusnetworks.com>
 <55E5EDB6.9050801@cumulusnetworks.com>
 <E82296F9-9C96-4589-B85B-0D12FB7BAAF4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35020 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbbIASj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:39:56 -0400
Received: by igbkq10 with SMTP id kq10so7983904igb.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:39:56 -0700 (PDT)
In-Reply-To: <E82296F9-9C96-4589-B85B-0D12FB7BAAF4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/15 12:39 PM, Nikolay Aleksandrov wrote:
>
>> On Sep 1, 2015, at 11:25 AM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
>>
>> for net-next. Forgot to add to subject line. (Thanks, Roopa, for the=
 reminder.)
>>
>> On 9/1/15 12:18 PM, David Ahern wrote:
>>> A number of VRF patches used 'int' for table id. It should be u32 t=
o be
>>> consistent with the rest of the stack.
>>>
>>> Fixes:
>>> 4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
>>> 15be405eb2ea9 ("net: Add inet_addr lookup by table")
>>> 30bbaa1950055 ("net: Fix up inet_addr_type checks")
>>> 021dd3b8a142d ("net: Add routes to the table associated with the de=
vice")
>>> dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
>>>
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>> ---
>>>   include/net/route.h      |  2 +-
>>>   include/net/vrf.h        | 24 ++++++++++++------------
>>>   net/ipv4/af_inet.c       |  2 +-
>>>   net/ipv4/fib_frontend.c  | 10 +++++-----
>>>   net/ipv4/fib_semantics.c |  2 +-
>>>   5 files changed, 20 insertions(+), 20 deletions(-)
> <<snip>>
>
> Should the fib_table_lookup tracepoint be updated as well ? It seems =
to be using
> int for tb_id even though it=92s a u32 in struct fib_table.
>

yes. good catch.

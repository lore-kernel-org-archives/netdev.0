From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Make table id type u32
Date: Tue, 1 Sep 2015 11:39:15 -0700
Message-ID: <E82296F9-9C96-4589-B85B-0D12FB7BAAF4@cumulusnetworks.com>
References: <1441131487-29367-1-git-send-email-dsa@cumulusnetworks.com> <55E5EDB6.9050801@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33298 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbIASjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:39:18 -0400
Received: by padan5 with SMTP id an5so4145913pad.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:39:18 -0700 (PDT)
In-Reply-To: <55E5EDB6.9050801@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 1, 2015, at 11:25 AM, David Ahern <dsa@cumulusnetworks.com> wr=
ote:
>=20
> for net-next. Forgot to add to subject line. (Thanks, Roopa, for the =
reminder.)
>=20
> On 9/1/15 12:18 PM, David Ahern wrote:
>> A number of VRF patches used 'int' for table id. It should be u32 to=
 be
>> consistent with the rest of the stack.
>>=20
>> Fixes:
>> 4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
>> 15be405eb2ea9 ("net: Add inet_addr lookup by table")
>> 30bbaa1950055 ("net: Fix up inet_addr_type checks")
>> 021dd3b8a142d ("net: Add routes to the table associated with the dev=
ice")
>> dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
>>=20
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>  include/net/route.h      |  2 +-
>>  include/net/vrf.h        | 24 ++++++++++++------------
>>  net/ipv4/af_inet.c       |  2 +-
>>  net/ipv4/fib_frontend.c  | 10 +++++-----
>>  net/ipv4/fib_semantics.c |  2 +-
>>  5 files changed, 20 insertions(+), 20 deletions(-)
<<snip>>

Should the fib_table_lookup tracepoint be updated as well ? It seems to=
 be using
int for tb_id even though it=92s a u32 in struct fib_table.

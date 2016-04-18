From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Mon, 18 Apr 2016 16:14:39 +0100
Message-ID: <5714F9DF.1040506@brocade.com>
References: <5711ADD1.2030904@brocade.com> <5714EDDB.8080306@brocade.com>
 <5714F199.7020608@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:16407 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752730AbcDRPO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 11:14:57 -0400
In-Reply-To: <5714F199.7020608@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2016 03:39 PM, David Ahern wrote:
> On 4/18/16 8:23 AM, Mike Manning wrote:
>> f1705ec197e7 "Make address flushing on ifdown optional" added the option
>> to retain user configured addresses on an admin down. A comment to one of
>> the later revisions suggested using the IFA_F_PERMANENT flag rather than
>> adding a user_managed boolean to the ifaddr struct. A side effect of this
>> change is that link local and loopback addresses were also retained which
>> was not part of the objective of the original changes. The fix 70af921db6f8
>> "Do not keep linklocal and loopback addresses" ensures that these are no
>> longer kept. Similarly, the present fix ensures that these addresses are not
>> fixed up either, otherwise the incorrect fixup triggers a crash in fib6.
>>
>> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> ---
>>   net/ipv6/addrconf.c |   13 +++++++------
>>   1 file changed, 7 insertions(+), 6 deletions(-)
> 
> Is this a v2? Code change is the same.

This is the same changeset, but Sergei requested on Saturday to change the wording as follows:


    scripts/checkpatch.pl now enforces commit citing certain style: <12-digit 

SHA1> ("<comit summary>").



> 
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

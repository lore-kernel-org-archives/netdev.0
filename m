From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls: Allow mpls_gso and mpls_router to be built
 as modules
Date: Tue, 10 Mar 2015 18:05:55 +0000
Message-ID: <54FF3283.7040702@brocade.com>
References: <1426005479-21806-1-git-send-email-rshearma@brocade.com> <87y4n4kc09.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:45065 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751027AbbCJSGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:06:40 -0400
In-Reply-To: <87y4n4kc09.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/15 17:17, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> CONFIG_MPLS=m doesn't result in a kernel module being built because it
>> applies to the net/mpls directory, rather than to .o files.
>>
>> So revert the MPLS menuitem to being a boolean and make MPLS_GSO and
>> MPLS_ROUTING tristates to allow mpls_gso and mpls_router modules to be
>> produced as desired.
>
> Good catch.  But I am pretty certain this does not result in the mpls
> routing code in af_mpls being built as a module either.

I'm pretty sure it does ;-)

   CC [M]  net/mpls/af_mpls.o
   LD [M]  net/mpls/mpls_router.o
   Building modules, stage 2.
   MODPOST 3010 modules
   LD [M]  net/mpls/mpls_router.ko

I deliberately split out the makefile rules so that the would be named 
mpls_router, rather than af_mpls to avoid any potential confusion with 
the mpls_gso module.

Thanks,
Rob

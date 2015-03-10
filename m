From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Allow mpls_gso and mpls_router to be built as modules
Date: Tue, 10 Mar 2015 13:07:40 -0500
Message-ID: <87y4n4iv4j.fsf@x220.int.ebiederm.org>
References: <1426005479-21806-1-git-send-email-rshearma@brocade.com>
	<87y4n4kc09.fsf@x220.int.ebiederm.org> <54FF3283.7040702@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41785 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbCJSLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:11:19 -0400
In-Reply-To: <54FF3283.7040702@brocade.com> (Robert Shearman's message of
	"Tue, 10 Mar 2015 18:05:55 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 10/03/15 17:17, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> CONFIG_MPLS=m doesn't result in a kernel module being built because it
>>> applies to the net/mpls directory, rather than to .o files.
>>>
>>> So revert the MPLS menuitem to being a boolean and make MPLS_GSO and
>>> MPLS_ROUTING tristates to allow mpls_gso and mpls_router modules to be
>>> produced as desired.
>>
>> Good catch.  But I am pretty certain this does not result in the mpls
>> routing code in af_mpls being built as a module either.
>
> I'm pretty sure it does ;-)
>
>   CC [M]  net/mpls/af_mpls.o
>   LD [M]  net/mpls/mpls_router.o
>   Building modules, stage 2.
>   MODPOST 3010 modules
>   LD [M]  net/mpls/mpls_router.ko
>
> I deliberately split out the makefile rules so that the would be named
> mpls_router, rather than af_mpls to avoid any potential confusion with
> the mpls_gso module.

Where do the files that go into mpls_router.o come from.

Ah.  I missed the mpls_route := af_mpls.o line.


Eric

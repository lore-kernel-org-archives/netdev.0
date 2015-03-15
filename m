From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/8] iproute2: Add a source addres length parameter to rt_addr_n2a
Date: Sun, 15 Mar 2015 14:42:11 -0500
Message-ID: <87lhiyoxnw.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:44542 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbCOTp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:45:58 -0400
In-Reply-To: <20150315123337.2694183a@urahara> (Stephen Hemminger's message of
	"Sun, 15 Mar 2015 12:33:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemming@brocade.com> writes:

> On Fri, 13 Mar 2015 18:52:09 +0000
> "Eric W. Biederman" <ebiederm@xmission.com> wrote:
>
>> 
>> For some address families (like AF_PACKET) it is helpful to have the
>> length when printing the address.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>  
>
> Recent changes to utils.h make this patch no longer apply cleanly.
> Please redo thanks.

Yeah the change to introduce af_bitlen does naturally cause some
conflicts.  I will fix things up and resend.

Patch application races are a pain.

Eric

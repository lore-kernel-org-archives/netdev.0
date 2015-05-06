From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Move reserved label definitions
Date: Wed, 06 May 2015 17:50:54 -0500
Message-ID: <87mw1hfhgx.fsf@x220.int.ebiederm.org>
References: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
	<20150506151656.137a0542@urahara>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38298 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbEFWzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:55:24 -0400
In-Reply-To: <20150506151656.137a0542@urahara> (Stephen Hemminger's message of
	"Wed, 6 May 2015 15:16:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 5 May 2015 09:06:30 -0700
> Tom Herbert <tom@herbertland.com> wrote:
>
>> Move to include/uapi/linux/mpls.h to be externally visibile.
>> 
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  include/uapi/linux/mpls.h | 10 ++++++++++
>>  net/mpls/af_mpls.c        | 18 +++++++++---------
>>  net/mpls/internal.h       | 10 ----------
>>  3 files changed, 19 insertions(+), 19 deletions(-)
>> 
>> diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
>
> You need to update include/uapi/linux/Kbuild to cause header
> to be exported.

This header is already exported in include/uapi/linux/Kbuild and
has been since before the recent mpls work.

Eric

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/2] net_sched: Remove broken tc actions
Date: Mon, 28 Oct 2013 18:57:29 -0400
Message-ID: <526EEBD9.8040006@mojatatu.com>
References: <87fvrmu909.fsf@xmission.com> <526D463E.6040000@mojatatu.com> <526D799C.9050905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:39806 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab3J1W5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 18:57:31 -0400
Received: by mail-qc0-f177.google.com with SMTP id u18so4247300qcx.36
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 15:57:31 -0700 (PDT)
In-Reply-To: <526D799C.9050905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/13 16:37, Alexander Duyck wrote:

> The primary use case for act_skbedit was to have it associated with a
> filter.  I based it off of act_simple so it isn't surprising that it
> inherited this issue.

Thats almost 100% of the use cases.

>
>  From what I can tell all of the other actions are just using
> tcf_hash_search for lookup.  Is there anything special that is needed in
> order to add the lookup call, or could we just add a one liner
> associating simple and skbedit lookup with tcf_hash_search?
>

Yes, that would do it. But dont bother - let me just send a generic
patch that will assume that for any other action that doesnt do it.
Will do it likely tomorow.


cheers,
jamal

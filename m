From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 5/5] net_sched: Fail if missing mandatory action operation
 methods
Date: Tue, 03 Dec 2013 19:43:20 -0500
Message-ID: <529E7AA8.4030906@mojatatu.com>
References: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>	<1386080600-4067-6-git-send-email-jhs@mojatatu.com> <20131203.114834.106107332355850481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:53738 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab3LDAnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 19:43:23 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so24712124ieb.4
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 16:43:23 -0800 (PST)
In-Reply-To: <20131203.114834.106107332355850481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/13 11:48, David Miller wrote:

> You are going to return with a lock held on error here.
>
> I was going to tell you not to do these fixups so late in the
> function, inside of the write lock, there is no reason for it.
>
> You should do all of this operation handling at the top of
> the function, before the write lock is taken.
>

yikes;->
do you want the whole set resent or the last one only?

cheers,
jamal

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: 32 bit net stats
Date: Mon, 23 Sep 2013 15:04:29 -0700
Message-ID: <1379973869.3165.27.camel@edumazet-glaptop>
References: <5240B771.8040307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:36324 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab3IWWEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 18:04:31 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so3734435pbc.31
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 15:04:30 -0700 (PDT)
In-Reply-To: <5240B771.8040307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 17:49 -0400, Jamal Hadi Salim wrote:
> Something broke in sending of 32 bit version of netstat around the
> time 64 bit version was improved. I went back as far as 3.8.0 to recent
> kernels. Could have been earlier.
> The work around in user space is when you see 64 bit stats just ignore
> the 32 bit version (which iproute2 does and so am i;->).
> 
> But assumming there are tools out there that know only of 32 bit
> variant they will get bad stats. Here's a compile tested only patch.
> Wont have to test anything for at least another day.
> 
> cheers,
> jamal
> 

Hi Jamal

Sorry, this doesnt make sense to me.

Existing code seems to be fine.

Which driver do you use ?

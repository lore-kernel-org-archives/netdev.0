From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 23:07:22 +0800
Message-ID: <AANLkTi=MFQc4_mYkwiKPzT_NmRRxou18P60ZZo+pYsNp@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <1291472282.2159.8.camel@mojatatu>
 <1291473756.2159.31.camel@mojatatu> <AANLkTikeECFUf0xiug7G+nd5=Sw7p=4Msz6RQ2gdOBzs@mail.gmail.com>
 <1291474793.2159.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37839 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab0LDPHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 10:07:43 -0500
Received: by fxm20 with SMTP id 20so3062763fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 07:07:42 -0800 (PST)
In-Reply-To: <1291474793.2159.43.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 10:59 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-12-04 at 22:50 +0800, Changli Gao wrote:
>
>> Maybe you misread my patch. tq is a stack variable in ri_tasklet, and
>> initialized all the time. ri_tasklet() won't exits until tq is
>> empty().
>
> in your patch is a variable on the stack.
> What i am saying is you should defer processing when there is an
> error (note the two other spots i mentioned).
> This means you may leave dp->tq non-empty and therefore it
> needs to be saved somewhere as it is before your patch.
>

I know what you concern now. Thanks. I'll keep the old behavior in v2.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)

From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 1 Apr 2009 18:44:47 +0200
Message-ID: <20090401164447.GA16626@elte.hu>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D39940.80801@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39796 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862AbZDAQpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 12:45:08 -0400
Content-Disposition: inline
In-Reply-To: <49D39940.80801@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Ingo Molnar wrote:
>>>                      : "memory", "cc");
>>> }
>>>     
>>
>> Hm, what's your point with pasting this inline function?
>>   
>
> He's pointing out the redundant (but harmless) "cc" clobber.

ah, yes. We are completely inconsistent about that. It doesnt
matter on x86 so i guess could be removed everywhere.

	Ingo

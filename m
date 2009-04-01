From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 09:41:36 -0700
Message-ID: <49D39940.80801@goop.org>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765761AbZDAQmB@vger.kernel.org>
In-Reply-To: <20090401161218.GB3859@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
>>                      : "memory", "cc");
>> }
>>     
>
> Hm, what's your point with pasting this inline function?
>   

He's pointing out the redundant (but harmless) "cc" clobber.

    J

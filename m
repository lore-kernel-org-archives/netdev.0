From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 23 Nov 2015 23:06:17 +0000
Message-ID: <87lh9o9uza.fsf@doppelsaurus.mobileactivedefense.com>
References: <87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
	<87vb8w2ulg.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151123.123033.522701221384821229.davem@davemloft.net>
	<87si3w9z3m.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, jbaron@akamai.com,
	dvyukov@google.com, syzkaller@googlegroups.com, mkubecek@suse.cz,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	kcc@google.com, glider@google.com, andreyknvl@google.com,
	sasha.levin@oracle.com, jln@google.com, keescook@google.com,
	minipli@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <87si3w9z3m.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Mon, 23 Nov 2015 21:37:17 +0000")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> David Miller <davem@davemloft.net> writes:

[...]

> I'm sorry for this 13th hour request/ suggestion but while thinking
> about a reply to Dmitry, it occurred to me that the restart_locked/
> sk_locked logic could be avoided by moving the test for this condition
> in front of all the others while leaving the 'act on it' code at its
> back, ie, reorganize unix_dgram_sendmsg such that it looks like this:

[...]

Just in case this is unclear on its own: If this was considered an
improvement by someone other than me, I could supply either a "complete"
patch with this re-arrangement or a cleanup delta patch changing the
previous change.

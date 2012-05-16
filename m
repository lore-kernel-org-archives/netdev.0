From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH/RFC net-next 0/4] Delete token ring support.
Date: Tue, 15 May 2012 21:38:49 -0400
Message-ID: <20120516013849.GA26701@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
 <m2k40dkl2o.fsf@firstfloor.org>
 <20120515.210020.1631343759962418692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <andi@firstfloor.org>, <netdev@vger.kernel.org>,
	<schwidefsky@de.ibm.com>, <heiko.carstens@de.ibm.com>,
	<linux390@de.ibm.com>, <linux-s390@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:36586 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932115Ab2EPBjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 21:39:01 -0400
Content-Disposition: inline
In-Reply-To: <20120515.210020.1631343759962418692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH/RFC net-next 0/4] Delete token ring support.] On 15/05/2012 (Tue 21:00) David Miller wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 15 May 2012 17:48:15 -0700
> 
> > Paul Gortmaker <paul.gortmaker@windriver.com> writes:
> >>
> >> What I mean by (2) is the implicit absence of anyone fixing _runtime_
> >> bugs, going all the way back to 2.6.12 in 2005.  If the code was being
> >> _used_, we'd see runtime regressions reported and their associated
> >> fixes.
> > 
> > Removal sounds good to me. In fact I would argue to remove any other driver
> > which did not get a real change since 2005 too.

3c501.c is on my radar.  The 8bit ISA hardware with discrete TTL
components everywhere was crap back in the early 1990s, and it sure as
hell has not got better with age.

> 
> I also support removing the token ring stuff, and in fact I'm more
> than happy to add your patch set to the net-next tree right now.

Great -- that was the kind of response I was hoping for, but not
expecting to get.  Let me run one last allyesconfig/allmodconfig
and I'll send a pull request.  I've already run the defconfig
build on s390 to make sure I didn't break them.

Thanks,
Paul.

From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 11:36:10 -0500
Message-ID: <20091227163609.GD12645@heat>
References: <20091227161203.GA20031@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Michael Stone <michael@laptop.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:50987 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752342AbZL0QeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2009 11:34:05 -0500
Content-Disposition: inline
In-Reply-To: <20091227161203.GA20031@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge Hallyn writes:
> Michael Stone writes:
>> The first reason why I'm not too worried is that anyone in a position to use
>> disablenetwork for nefarious purposes is also probably able to use ptrace(),
>> kill(), and/or LD_PRELOAD to similar ends.
> 
> How do you mean?  

I meant that, with the current interface, to set disablenetwork for pid P, you
have either be pid P or to have been one of P's ancestors. In either case, you
have lots of opportunity to mess with P's environment. 

> I thought that disabling network was a completely
> unprivileged operation?  And subsequently executing a setuid-root
> application won't reset the flag.

Correct and correct for the current patches.

>> The second reason why I'm not too worried is that I believe it to be
>> straightforward to use the pre-existing MAC frameworks to prevent individually
>> important processes from dropping networking privileges.
>>
>> Do you have a specific concern in mind not addressed by either of these
>> observations?
>
> Near as I can tell the worst one could do would be to prevent remote
> admins from getting useful audit messages, which could give you unlimited
> time to keep re-trying the server, on your quest to a brute-force attack
> of some sort, i.e. restarting the server with random passwords, and now
> no audit msg about the wrong password gets generated, so you're free to
> exhaust the space of valid passwords.
> 
> Not saying I'm all that worried about it - just something that came to
> mind.

I'll think about it further. Fortunately, there's no need to be hasty. :)

Michael

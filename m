From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 1/3] Security: Add disablenetwork interface. (v4)
Date: Mon, 28 Dec 2009 20:25:23 -0500
Message-ID: <20091229012523.GB14362@heat>
References: <20091227075335.GA11737@elf.ucw.cz>
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
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Michael Stone <michael@lapt
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:60355 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752481AbZL2BXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 20:23:15 -0500
Content-Disposition: inline
In-Reply-To: <20091227075335.GA11737@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek wrote:
>> index 26a6b73..b48f021 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -35,6 +35,7 @@
>>   #include <linux/cpu.h>
>>   #include <linux/ptrace.h>
>>   #include <linux/fs_struct.h>
>> +#include <linux/prctl_network.h>
>>   
>>   #include <linux/compat.h>
>>   #include <linux/syscalls.h>
>
> Something seems to be wrong with whitespace here. Damaged patch?

Nope; kernel/sys.c has a newline there:

   http://repo.or.cz/w/linux-2.6.git/blob/HEAD:/kernel/sys.c#l36

Shall I remove it?

Michael

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 10:07:53 +0900
Message-ID: <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>
References: <20100110215848.GA26609@elf.ucw.cz>
	<20100110224010.GA3825@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, andi@firstfloor.org,
	david@lang.hm, socketcan@hartkopp.net, alan@lxorguk.ukuu.org.uk,
	herbert@gondor.apana.org.au, Valdis.Kletnieks@vt.edu,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, penguin-kernel@i-love.sakura.ne.jp,
	sam@synack.fr, casey@schaufler-ca.com, serue@us.ibm.com,
	viro@ZenIV.linux.org.uk
To: michael@laptop.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100110224010.GA3825@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone wrote:
> Examples of software that I want to be able to gain privileges normally include:
> 
>    rainbow, which requires privilege in order to add new accounts to the system
>    and in order to call setuid() but which does not require networking
>    privileges.

If the system is not using local files (i.e. /etc/passwd and /etc/shadow),
the process who wants to add new accounts to the system might need network
access (e.g. to LDAP server), doesn't it?

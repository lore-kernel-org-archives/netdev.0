From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 18 Jan 2010 07:56:47 -0800
Message-ID: <551280e51001180756q2a438d3cv99bbb4e87eb073f4@mail.gmail.com>
References: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
	 <20100110215409.GA3705@heat> <20100110215848.GA26609@elf.ucw.cz>
	 <5768.1263264853@localhost>
	 <20100112075927.GA24256@atrey.karlin.mff.cuni.cz>
	 <32558.1263306523@localhost>
	 <20100114092250.GA11500@atrey.karlin.mff.cuni.cz>
	 <17852.1263819244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>, Michael Stone <michael@laptop.org>,
	James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"Am?rico Wang" <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Al Viro <viro@zeniv.linu
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <17852.1263819244@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2010 at 4:54 AM,  <Valdis.Kletnieks@vt.edu> wrote:
> (Interestingly enough, the capabilities bug came *later*:
>
> 8.12.1/8.12.1 =A0 2001/10/01
> =A0 =A0 =A0 =A0SECURITY: Check whether dropping group privileges actu=
ally succeeded
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0to avoid possible compromises of the m=
ail system by
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0supplying bogus data. =A0Add configura=
tion options for
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0different set*gid() calls to reset sav=
ed gid. =A0Problem
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0found by Michal Zalewski.
>
> and was mostly an issue because the same problem existed in pre-8.12 =
sendmails
> that were still setuid and hadn't upgraded yet...
>
>

I think the above was 'a' sendmail bug. 'The' capabilities bug came bef=
ore that:

http://userweb.kernel.org/~morgan/sendmail-capabilities-war-story.html

Cheers

Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

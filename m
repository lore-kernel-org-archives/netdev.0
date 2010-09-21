From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Tue, 21 Sep 2010 22:56:00 +0300
Message-ID: <1285098960.10579.14.camel@powerslave>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
	 <1282570935.7198.5.camel@powerslave>
	 <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
	 <1282589101.7198.28.camel@powerslave>
	 <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>
	 <1282633220.7198.123.camel@powerslave>
	 <alpine.LNX.2.01.1008240921230.24349@obet.zrqbmnf.qr>
	 <1282720198.18016.72.camel@powerslave>
	 <alpine.LNX.2.01.1008251103150.24022@obet.zrqbmnf.qr>
	 <1282895723.2006.135.camel@powerslave>  <4C91292F.3090602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Jan Engelhardt <jengelh@medozas.de>,
	"Makela Juhani.3 (EXT-Nixu/Helsinki)" <ext-juhani.3.makela@nokia.com>,
	ext Changli Gao <xiaosuo@gmail.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4C91292F.3090602@trash.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 22:14 +0200, ext Patrick McHardy wrote:
> Am 27.08.2010 09:55, schrieb Luciano Coelho:
> > That's what I tried to say when I said that we have a security team
> > taking care of this.  They are implementing solutions to make the
> > product more secure, defending it against malware, misuse, attacks and
> > other such things.  In this specific case, security-wise, we are trying
> > to prevent some bogus or malicious application from changing our
> > netfilter rules and causing havoc.
> > 
> > LSM doesn't seem to be an option, here I quote Juhani (my colleague from
> > our security team):
> > 
> >> The problem with capabilites is that they are assigned to binaries, not
> >> users. Kind of a setuid-mechanism, really. In our embedded environment
> >> that makes a lot of sense, but in a server-type environment with
> >> multiple users and a competent sysadmin, not so much. In such an
> >> environment using a LSM might also actually make sense. But for us it's
> >> not an option, mostly because LSMs are not stackable - you can have only
> >> one effective at any time - and I'm afraid we have already reserved some
> >> of the LSM hooks.
> > 
> > Maybe Juhani can clarify this a bit more.
> > 
> > One other idea that Juhani had was to add an option to the condition
> > match/target where the capability requiremets could be set, instead of
> > checking them by default.  If nothing is specified, everything still
> > works as before (no caps checks).  Or even a Kconfig option?
> 
> I agree with Jan, adding module parameters to control permission checks
> or capabilities seems like a bad precedent.

Okay, the idea is now officially dropped.  We'll use normal ACL to
control access to the conditions.

Thanks for your comments and sorry for trying to push ;)


-- 
Cheers,
Luca.


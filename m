From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Mon, 23 Aug 2010 20:58:05 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1008232052170.31619@obet.zrqbmnf.qr>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>  <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>  <1282570935.7198.5.camel@powerslave>  <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
 <1282589101.7198.28.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1282589101.7198.28.camel@powerslave>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2010-08-23 20:45, Luciano Coelho wrote:
>> But it looks as strange as the Yama code attempt.
>
>What is so strange about it? Is it because it's possible to set the
>capability requirement from modprobe arguments? The capability check
>already exists in at least in nfnetlink, where it checks for received
>messages for the CAP_NET_ADMIN capability.  Is it strange because we're
>checking for the capability when someone tries to write to a file?

It is strange that you check this capability from a module focused on
packet handling. For lack of a better example, it's as if you tried
to check the uid of the file, the latter of which is better left to
the routines in fs/.

>>  This is the one time 
>> where I would personally be looking into SELinux, or perhaps SMACK if 
>> the former is too complex, to whether _t'ing off procfs is possible.
>
>Yeah, but it's not up to me to decide this.  We have one entire team
>dedicated to figuring out how to ensure "security" in our device.  It
>was that team who advised us to protect this file by checking for
>CAP_NET_ADMIN.

You can do whatever you want with your product. I am just saying this
does not look like kernel material, and I suppose it won't go well
with the maintainers up the chain either.

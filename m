From: Solar Designer <solar@openwall.com>
Subject: Re: [PATCH v4 next 0/3] modules: automatic module loading restrictions
Date: Mon, 22 May 2017 14:08:48 +0200
Message-ID: <20170522120848.GA3003@openwall.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Pete
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <kernel-hardening-return-7964-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
List-Id: netdev.vger.kernel.org

Hi Djalal,

Thank you for your work on this!

On Mon, May 22, 2017 at 01:57:03PM +0200, Djalal Harouni wrote:
> *) When modules_autoload_mode is set to (2), automatic module loading is
> disabled for all. Once set, this value can not be changed.

What purpose does this securelevel-like property ("Once set, this value
can not be changed.") serve here?  I think this mode 2 is needed, but
without this extra property, which is bypassable by e.g. explicitly
loaded kernel modules anyway (and that's OK).

I'm sorry if this has been discussed before.

Alexander

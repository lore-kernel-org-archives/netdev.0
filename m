From: Nick Andrew <nick@nick-andrew.net>
Subject: Re: About git-bisect (defconfigs)
Date: Thu, 4 Dec 2008 11:14:52 +1100
Message-ID: <20081204001452.GH11807@mail.local.tull.net>
References: <bEFPF-XO-15@gated-at.bofh.it> <bEFPG-XO-19@gated-at.bofh.it> <bEG8P-1xl-15@gated-at.bofh.it> <bEGiz-1Hw-11@gated-at.bofh.it> <bEGLI-2aS-31@gated-at.bofh.it> <bEGVc-2Bk-11@gated-at.bofh.it> <m2r64q6y8e.fsf@gmail.com> <493681B7.20101@diamondcut.com.br> <38b2ab8a0812030924g5391fdbdy15c472a51ab24aef@mail.gmail.com> <4936C6FB.4020201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francis Moreau <francis.moro@gmail.com>,
	"Renato S. Yamane" <yamane@diamondcut.com.br>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757390AbYLDAPa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4936C6FB.4020201@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2008 at 09:50:51AM -0800, Randy Dunlap wrote:
> 2.  There are several security-related config items that default to =y but the
> kconfig help says:  If unsure, say N here.  Like:
> 
> 
> CONFIG_NETLABEL=y
> CONFIG_NETWORK_SECMARK=y
> CONFIG_KEYS=y
> CONFIG_SECURITY=y
> CONFIG_SECURITY_NETWORK=y
> CONFIG_SECURITY_SELINUX=y
> 
> Maybe I just don't understand the current meaning/usage of defconfig.  eh?

A consistent approach to the Kconfig hints would help. To me,
"If unsure, say N" implies that turning off the feature won't break
the kernel nor be anything particularly important. The Kconfig hints
should follow the defaults (or else why default to 'y'?) for common
architectures.

Perhaps menuconfig can generate the "If unsure" message itself from
the architecture defaults? That will ensure consistency.

Nick.

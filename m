From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Wed, 30 Dec 2009 21:29:31 +0000
Message-ID: <20091230212931.233003b9@lxorguk.ukuu.org.uk>
References: <m1iqbpwjtp.fsf@fess.ebiederm.org>
	<20091229223631.GB22578@us.ibm.com>
	<m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
	<3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
	<m1d41w62zc.fsf_-_@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com>
	<m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753816AbZL3V3P@vger.kernel.org>
In-Reply-To: <m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Added bprm->nosuid to make remove the need to add
> duplicate error prone checks.  This ensures that
> the disabling of suid executables is exactly the
> same as MNT_NOSUID.

Another fine example of why we have security hooks so that we don't get a
kernel full of other "random security idea of the day" hacks.


Alan

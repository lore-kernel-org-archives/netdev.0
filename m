From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
	interface. (v3)
Date: Thu, 24 Dec 2009 00:44:00 -0500
Message-ID: <20091224054359.GA24396@heat>
References: <m2pr653s1l.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
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
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m2pr653s1l.fsf@ssh.synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think this is unnecessary, as LSM module, you should use the
> void* security member of the structure cred. 

The change you propose is easily made but I'm having trouble seeing how making
it would help my purpose: the field you name is already in use by other parts
of the kernel which my functionality is intended to complement.

That being said, I'd be very happy to prepare a version of the patch using the
strategy you suggest if it would be directly useful to you or if you can show
me how it would contribute to my goals.

Regards, and thanks for your comment,

Michael

P.S. - Perhaps a reasonable alternative would be to the definition of the field
conditional on CONFIGURE_SECURITY_PRCTL_NETWORK?

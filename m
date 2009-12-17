From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 13:24:50 -0500
Message-ID: <3e8340490912171024n2120e88q569c69fe7d09140f@mail.gmail.com>
References: <m1ljh7jijk.fsf@fess.ebiederm.org> <20091213142149.GB4777@heat>
	<fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Stone <michael@laptop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Mark Seaborn <mrs@mythic-beasts.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2009 at 12:31 PM, Mark Seaborn <mrs@mythic-beasts.com> wrote:

> Maybe we could fix (b) by making mount namespaces into first class objects
> that can be named through a file descriptor, so that one process can
> manipulate another process's namespace without itself being subject to the
> namespace.

Can this be done using openat() and friends currently? It would seem
the natural way to implement this; open /proc/(pid)/root, then
openat() things from there (or even chdir to it and see the mounts
that it sees from there...)

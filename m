From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 18:09:26 +0100
Message-ID: <CAHmME9ruYEJbLOij9ooYxLNgkOfr6F9c87dJjD3D_aFVsEFJZQ@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161215232840.22459.qmail@ns.sciencehorizons.net> <063D6719AE5E284EB5DD2968C1650D6DB0241238@AcuExch.aculab.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>, "ak@linux.intel.com" <ak@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>, "ebiggers3@gmail.com" <ebiggers3@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"jeanphilippe.aumasson@gmail.com" <jeanphilippe.aumasson@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "luto@amacapital.net" <luto@amacapital.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "tom@herbertland.com" <tom@herbertland.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "tytso@mit.edu" <tytso@mit.edu>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>, "djb@cr.yp.to" <djb@cr.yp.to>
To: David Laight <David.Laight@aculab.com>
Return-path: <kernel-hardening-return-5641-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0241238@AcuExch.aculab.com>
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Dec 16, 2016 at 6:06 PM, David Laight <David.Laight@aculab.com> wrote:
> A 32bit hash would also remove all the issues about the alignment
> of IP addresses (etc) on 64bit systems.

The current replacements of md5_transform with siphash in the v6 patch
series will continue to use the original siphash, since the 128-bit
key is rather important for these kinds of secrets. Additionally,
64-bit siphash is already faster than the md5_transform that it
replaces. So the alignment concerns (now, non-issues; problems have
been solved, I believe) still remain.

Jason

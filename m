From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable
 function
Date: Sat, 17 Dec 2016 16:06:15 -0800 (PST)
Message-ID: <alpine.DEB.2.20.99.1612171601430.31470@trent.utfs.org>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com> <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com> <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com> <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com> <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com> <CALx6S349hOFhnMgM_TgKXC1O7bmOvR87Nm=5B7_sNLEWiZU8Zg@mail.gmail.com>
 <CAHmME9qNcsXtdWO_rmngSXXeBsTbA9B_33oLJ_pWOWcO7P2JZg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Tom Herbert <tom@herbertland.com>, Netdev <netdev@vger.kernel.org>,
    kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>,
    Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
    Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
    "Daniel J . Bernstein" <djb@cr.yp.to>,
    Linus Torvalds <torvalds@linux-foundation.org>,
    Eric Biggers <ebiggers3@gmail.com>, David Laight <David.Laight@aculab.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5694-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9qNcsXtdWO_rmngSXXeBsTbA9B_33oLJ_pWOWcO7P2JZg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, 15 Dec 2016, Jason A. Donenfeld wrote:
> > I'd still drop the "24" unless you really think we're going to have
> > multiple variants coming into the kernel.
> 
> Okay. I don't have a problem with this, unless anybody has some reason
> to the contrary.

What if the 2/4-round version falls and we need more rounds to withstand 
future cryptoanalysis? We'd then have siphash_ and siphash48_ functions, 
no? My amateurish bike-shedding argument would be "let's keep the 24 then" :-)

C.
-- 
BOFH excuse #354:

Chewing gum on /dev/sd3c

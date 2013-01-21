From: David Dillow <dave@thedillows.org>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 04:18:01 -0500
Message-ID: <1358759881.2595.15.camel@obelisk.thedillows.org>
References: <861997288.94032.1358728848956.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <861997288.94032.1358728848956.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-20 at 19:40 -0500, Tom St Denis wrote:
> The problem is for me to add the ()'s is a no brainer.

It was more than just the ()'s. You completely botched the indentation
in the parts of code you didn't copy from xcbc.c, among other issues.

> For me to re-write complete statements for coding style reasons means
> I have to actually go out and test it again.

Well, for some of the code you submitted, that would be the first
testing it got, even compile testing AFAICT. I don't doubt that you
tested against your hardware, but it is obvious that you didn't run the
algorithm tests you added, or even tried to compile them. You were
missing a semicolon after your test data, and you were also missing a
"\x" in there, so your test data was wrong.

I know this, because I just spent the five minutes required to fix up
the checkpatch warnings to prove to myself that you could have done it
faster than sending one considered message to the list about how much we
suck. Of course, that assumes you are trying to have a discussion
instead of trolling; it's much easier to spew bile than to think before
you post.

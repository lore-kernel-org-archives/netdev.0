From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 21:15:03 -0500
Message-ID: <20161217021503.32767.qmail@ns.sciencehorizons.net>
References: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
  djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
  jeanphilippe.aumasson@gmail.com, kernel-hardening@lists.openwall.com,
  linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
  luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
  torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
To: Jason@zx2c4.com, linux@sciencehorizons.net
Return-path: <kernel-hardening-return-5688-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

> I already did this. Check my branch.

Do you think it should return "u32" (as you currently have it) or
"unsigned long"?  I thought the latter, since it doesn't cost any
more and makes more 

> I wonder if this could also lead to a similar aliasing
> with arch_get_random_int, since I'm pretty sure all rdrand-like
> instructions return native word size anyway.

Well, Intel's can return 16, 32 or 64 bits, and it makes a
small difference with reseed scheduling.

>> - Ted, Andy Lutorminski and I will try to figure out a construction of
>>   get_random_long() that we all like.

> And me, I hope... No need to make this exclusive.

Gaah, engage brain before fingers.  That was so obvious I didn't say
it, and the result came out sounding extremely rude.

A better (but longer) way to write it would be "I'm sorry that I, Ted,
and Andy are all arguing with you and each other about how to do this
and we can't finalize this part yet".

From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [GIT] Networking
Date: Fri, 4 Sep 2015 09:07:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8D542@AcuExch.aculab.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
 <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
 <20150903.104032.767889134756094076.davem@davemloft.net>
 <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
 <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
 <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: 'Marcel Holtmann' <marcel@holtmann.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I find them useful as syntactic sugar. We have not used them a lot, but there are cases in our crypto
> handling code where we have fixed size array inputs/outputs and there we opted to use them. They make
> it easy to remember what the expected sizes of input and output are without having to read through the
> implementation (of course we never even tried to use sizeof on these pointers).
> 
> static int smp_ah(struct crypto_blkcipher *tfm, const u8 irk[16],
>                   const u8 r[3], u8 res[3])

Expect that it looks like you are passing arrays by value,
but instead you are passing by reference.

Explicitly pass by reference and sizeof works.
The object code will be the same.

	David

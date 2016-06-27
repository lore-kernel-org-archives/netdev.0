From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 01/29] bluetooth: Switch SMP to crypto_cipher_encrypt_one()
Date: Tue, 28 Jun 2016 00:30:24 +0200
Message-ID: <2833CC26-7306-4803-A5DB-4CBECCF35C08@holtmann.org>
References: <cover.1466974736.git.luto@kernel.org> <cover.1466974736.git.luto@kernel.org> <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1466974736.git.luto@kernel.org> <8C5360E3-94EE-4869-B9B9-AF9D41B5A3AC@holtmann.org> <20160627085403.GA26865@gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Andy Lutomirski <luto@kernel.org>,
 x86@kernel.org,
 LKML <linux-kernel@vger.kernel.org>,
 linux-arch@vger.kernel.org,
 Borislav Petkov <bp@alien8.de>,
 Nadav Amit <nadav.amit@gmail.com>,
 Kees Cook <keescook@chromium.org>,
 Brian Gerst <brgerst@gmail.com>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Josh Poimboeuf <jpoimboe@redhat.com>,
 Jann Horn <jann@thejh.net>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "Gustavo F. Padovan" <gustavo@padovan.org>,
 Johan Hedberg <johan.hedberg@gmail.com>,
 "David S. Miller" <davem@davemloft.net>,
 linux-bluetooth@vger.kernel.org,
 netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <kernel-hardening-return-3741-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160627085403.GA26865@gmail.com>
List-Id: netdev.vger.kernel.org

Hi Ingo,

>>> SMP does ECB crypto on stack buffers.  This is complicated and
>>> fragile, and it will not work if the stack is virtually allocated.
>>>=20
>>> Switch to the crypto_cipher interface, which is simpler and safer.
>>>=20
>>> Cc: Marcel Holtmann <marcel@holtmann.org>
>>> Cc: Gustavo Padovan <gustavo@padovan.org>
>>> Cc: Johan Hedberg <johan.hedberg@gmail.com>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: linux-bluetooth@vger.kernel.org
>>> Cc: netdev@vger.kernel.org
>>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>>> Acked-and-tested-by: Johan Hedberg <johan.hedberg@intel.com>
>>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>>> ---
>>> net/bluetooth/smp.c | 67 =
++++++++++++++++++++++-------------------------------
>>> 1 file changed, 28 insertions(+), 39 deletions(-)
>>=20
>> patch has been applied to bluetooth-next tree.
>=20
> Sadly carrying this separately will delay the virtual kernel stacks =
feature by a=20
> kernel cycle, because it's a must-have prerequisite.

I can take it back out, but then I have the fear the the ECDH change to =
use KPP for SMP might be the one that has to wait a kernel cycle. Either =
way is fine with me, but I want to avoid nasty merge conflicts in the =
Bluetooth SMP code.

Regards

Marcel

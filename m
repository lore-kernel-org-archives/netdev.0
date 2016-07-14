From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v5 01/32] bluetooth: Switch SMP to crypto_cipher_encrypt_one()
Date: Thu, 14 Jul 2016 21:30:15 +0100
Message-ID: <4AED1BFF-7BBD-465C-B9F6-532B1B864346@holtmann.org>
References: <cover.1468270393.git.luto@kernel.org> <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1468270393.git.luto@kernel.org> <CALCETrXYNM_b41J30eSuuhKtPRUANFpTh6bfuHM4-_RYGuZbZw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Andy Lutomirski <luto@kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 X86 ML <x86@kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-arch <linux-arch@vger.kernel.org>,
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
 linux-bluetooth@vger.kernel.org,
 Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-3982-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXYNM_b41J30eSuuhKtPRUANFpTh6bfuHM4-_RYGuZbZw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi Andy,

>> SMP does ECB crypto on stack buffers.  This is complicated and
>> fragile, and it will not work if the stack is virtually allocated.
>>=20
>> Switch to the crypto_cipher interface, which is simpler and safer.
>=20
> Hi Dave-
>=20
> It looks like we're delaying virtually mapped stacks to 4.9.  That
> means that there's time for this to go in through net-next.  Could you
> queue it up?

it is actually already in net-next since we decided to let git handle =
any potential merge issue.

Regards

Marcel

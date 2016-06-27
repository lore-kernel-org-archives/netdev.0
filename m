From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 01/29] bluetooth: Switch SMP to
 crypto_cipher_encrypt_one()
Date: Mon, 27 Jun 2016 10:54:03 +0200
Message-ID: <20160627085403.GA26865@gmail.com>
References: <cover.1466974736.git.luto@kernel.org>
 <cover.1466974736.git.luto@kernel.org>
 <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1466974736.git.luto@kernel.org>
 <8C5360E3-94EE-4869-B9B9-AF9D41B5A3AC@holtmann.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>, x86@kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
	Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>,
	Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <kernel-hardening-return-3728-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: Ingo Molnar <mingo.kernel.org@gmail.com>
Content-Disposition: inline
In-Reply-To: <8C5360E3-94EE-4869-B9B9-AF9D41B5A3AC@holtmann.org>
List-Id: netdev.vger.kernel.org


* Marcel Holtmann <marcel@holtmann.org> wrote:

> Hi Andy,
> 
> > SMP does ECB crypto on stack buffers.  This is complicated and
> > fragile, and it will not work if the stack is virtually allocated.
> > 
> > Switch to the crypto_cipher interface, which is simpler and safer.
> > 
> > Cc: Marcel Holtmann <marcel@holtmann.org>
> > Cc: Gustavo Padovan <gustavo@padovan.org>
> > Cc: Johan Hedberg <johan.hedberg@gmail.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: linux-bluetooth@vger.kernel.org
> > Cc: netdev@vger.kernel.org
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> > Acked-and-tested-by: Johan Hedberg <johan.hedberg@intel.com>
> > Signed-off-by: Andy Lutomirski <luto@kernel.org>
> > ---
> > net/bluetooth/smp.c | 67 ++++++++++++++++++++++-------------------------------
> > 1 file changed, 28 insertions(+), 39 deletions(-)
> 
> patch has been applied to bluetooth-next tree.

Sadly carrying this separately will delay the virtual kernel stacks feature by a 
kernel cycle, because it's a must-have prerequisite.

Thanks,

	Ingo

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 01/32] bluetooth: Switch SMP to
 crypto_cipher_encrypt_one()
Date: Thu, 14 Jul 2016 13:41:44 -0700 (PDT)
Message-ID: <20160714.134144.1427497707130106328.davem@davemloft.net>
References: <cover.1468270393.git.luto@kernel.org>
	<264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1468270393.git.luto@kernel.org>
	<CALCETrXYNM_b41J30eSuuhKtPRUANFpTh6bfuHM4-_RYGuZbZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, bp@alien8.de, nadav.amit@gmail.com,
	keescook@chromium.org, brgerst@gmail.com,
	kernel-hardening@lists.openwall.com, torvalds@linux-foundation.org,
	jpoimboe@redhat.com, jann@thejh.net, heiko.carstens@de.ibm.com,
	marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CALCETrXYNM_b41J30eSuuhKtPRUANFpTh6bfuHM4-_RYGuZbZw@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 14 Jul 2016 12:10:45 -0700

> On Mon, Jul 11, 2016 at 1:53 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> SMP does ECB crypto on stack buffers.  This is complicated and
>> fragile, and it will not work if the stack is virtually allocated.
>>
>> Switch to the crypto_cipher interface, which is simpler and safer.
> 
> Hi Dave-
> 
> It looks like we're delaying virtually mapped stacks to 4.9.  That
> means that there's time for this to go in through net-next.  Could you
> queue it up?

This needs to go via the bluetooth maintainer, who will surely pass
it properly my way.

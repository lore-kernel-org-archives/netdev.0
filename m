From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 22:21:50 +0100
Message-ID: <CAHmME9rgGnAYTDaPSo=7mZj=jinka0+QTYA8TBb9WXY9S1QmRg@mail.gmail.com>
References: <20161214184605.24006-1-Jason@zx2c4.com> <201612150515.xggXiOp3%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201612150515.xggXiOp3%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interesting. Evidently gcc 4.8 doesn't like my use of:

enum siphash_lengths {
       SIPHASH24_KEY_LEN = 16,
       SIPHASH24_ALIGNMENT = 8
};

I'll convert this to the more boring:

#define SIPHASH24_KEY_LEN 16
#define SIPHASH24_ALIGNMENT 8

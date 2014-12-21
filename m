From: Ilya Dryomov <ilya.dryomov@inktank.com>
Subject: Re: [PATCH] net: ceph: crypto.c: Remove some unused functions
Date: Sun, 21 Dec 2014 14:16:10 +0300
Message-ID: <CALFYKtAO5pK8CuM+zQPdHJHrjO=2DErDT4kDzga1sZUkLpAsxA@mail.gmail.com>
References: <1419094326-9218-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1419094326-9218-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 20, 2014 at 7:52 PM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Removes some functions that are not used anywhere:
> ceph_encrypt() ceph_decrypt() ceph_crypto_key_encode()
>
> This was partially found by using a static code analysis program called cppcheck.

I'd like to keep this stuff even if it's unused, unless Sage/others
want it gone.  ceph_crypto_key_encode() is ceph_crypto_key_decode()'s
counterpart and ceph_{en,de}crypt() are useful for reference purposes.

Thanks,

                Ilya

From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH 0/3] crypto: af_alg - add TLS type encryption
Date: Wed, 13 Apr 2016 15:46:00 -0700
Message-ID: <570ECC28.3030008@intel.com>
References: <20160306012044.6369.63924.stgit@tstruk-mobl1>
 <20160405112940.GB11852@gondor.apana.org.au> <57054DBC.8010507@intel.com>
 <20160408025250.GA7596@gondor.apana.org.au>
 <CALx6S37m_ayZJ4nth0SPNr2Km2+uBZUCtK4iqPKHTARv2eB4aA@mail.gmail.com>
 <570CD852.7060003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	davejwatson@fb.com, nmav@gnutls.org, fridolin.pokorny@gmail.com
To: Fridolin Pokorny <fpokorny@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <570CD852.7060003@redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fridolin,
On 04/12/2016 04:13 AM, Fridolin Pokorny wrote:
> we were experimenting with this. We have a prove of concept of a kernel
> TLS type socket, so called AF_KTLS, which is based on Dave Watson's
> RFC5288 patch. It handles both TLS and DTLS, unfortunately it is not
> ready now to be proposed here. There are still issues which should be
> solved (but mostly user space API design) [1]. If you are interested, we
> could combine efforts.
> 
> Regards,
> Fridolin Pokorny
> 
> [1] https://github.com/fridex/af_ktls

I had a quick look and it looks like is limited only to gcm(aes). 
I would be more interested to have a generic interface that could do generic algorithm
suits like aes-cbc-hmac-sha1 also.
This also seems to work in a synchronous (send one and wait) mode, which is a not good
solution for HW accelerators, which I'm trying to enable.
Thanks,
-- 
TS

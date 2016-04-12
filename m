From: Fridolin Pokorny <fpokorny@redhat.com>
Subject: Re: [PATCH 0/3] crypto: af_alg - add TLS type encryption
Date: Tue, 12 Apr 2016 13:13:22 +0200
Message-ID: <570CD852.7060003@redhat.com>
References: <20160306012044.6369.63924.stgit@tstruk-mobl1>
 <20160405112940.GB11852@gondor.apana.org.au> <57054DBC.8010507@intel.com>
 <20160408025250.GA7596@gondor.apana.org.au>
 <CALx6S37m_ayZJ4nth0SPNr2Km2+uBZUCtK4iqPKHTARv2eB4aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	davejwatson@fb.com, nmav@gnutls.org, fridolin.pokorny@gmail.com
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALx6S37m_ayZJ4nth0SPNr2Km2+uBZUCtK4iqPKHTARv2eB4aA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08.04.2016 04:58, Tom Herbert wrote:
> On Thu, Apr 7, 2016 at 11:52 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Wed, Apr 06, 2016 at 10:56:12AM -0700, Tadeusz Struk wrote:
>>>
>>> The intend is to enable HW acceleration of the TLS protocol.
>>> The way it will work is that the user space will send a packet of data
>>> via AF_ALG and HW will authenticate and encrypt it in one go.
>>
>> There have been suggestions to implement TLS data-path within
>> the kernel.  So we should decide whether we pursue that or go
>> with your approach before we start adding algorithms.
>>
> Yes, please see Dave Watson's patches on this.
> 


Hi Tadeusz,

we were experimenting with this. We have a prove of concept of a kernel
TLS type socket, so called AF_KTLS, which is based on Dave Watson's
RFC5288 patch. It handles both TLS and DTLS, unfortunately it is not
ready now to be proposed here. There are still issues which should be
solved (but mostly user space API design) [1]. If you are interested, we
could combine efforts.

Regards,
Fridolin Pokorny

[1] https://github.com/fridex/af_ktls

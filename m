From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Wed, 23 Jun 2010 19:52:54 +1000
Message-ID: <20100623095254.GA32491@gondor.apana.org.au>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam> <20100608052744.GA21547@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com> <20100611052112.GA25649@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com> <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com> <1A42CE6F5F474C41B63392A5F80372B21F58CD9A@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Dong, Eddie" <eddie.dong@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1A42CE6F5F474C41B63392A5F80372B21F58CD9A@shsmsx501.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 23, 2010 at 04:09:40PM +0800, Dong, Eddie wrote:
>
> Xiaohui & Herbert:
> 	Mixing copy of head & 0-copy of bulk data imposes additional challange to find the guest buffer. The backend driver may be unable to find a spare guest buffer from virtqueue at that time which may block the receiving process then.
> 	Can't we completely eliminate netdev_alloc_skb here? Assigning guest buffer at this time makes life much easier.

I'm not sure I understand you concern.  If you mean that when
the guest doesn't give enough pages to the host and the host
can't receive on behalf of the guest then isn't that already
the case with the original patch-set?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Sporadic ESP payload corruption when using IPSec in NAT-T
 Transport Mode
Date: Mon, 3 Nov 2014 15:18:56 +0800
Message-ID: <20141103071856.GA28745@gondor.apana.org.au>
References: <CALEwOppDfAHV2rghk_nO2Xbjqxd=cbUeW7oWOkAgZtcmjPdHuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mwoodson@redhat.com
To: Evan Gilman <evan@pagerduty.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALEwOppDfAHV2rghk_nO2Xbjqxd=cbUeW7oWOkAgZtcmjPdHuQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evan Gilman <evan@pagerduty.com> wrote:
>
> I tried to find a reference to the previous report of aesni-intel
> causing IPSec corruption under Xen - I'd be interested to read it if
> anyone here has it on hand. For now, we are looking to blacklist
> aesni-intel as we have no other suitable solution, and when combined
> with our other bug, has a detrimental effect on our infrastructure.

Unfortunately the bug is marked as private but it's

https://bugzilla.redhat.com/show_bug.cgi?id=1085025

FWIW it was also observed on AWS.  There is speculation that
switching to HVM may fix it.  If that were the case, then it's
highly likely that this is a bug in the Xen paravirt code.

It would also mean that if you cannot switch over to HVM then
the most appropriate fix would be to not use aesni-intel.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

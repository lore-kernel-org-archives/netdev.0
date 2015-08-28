From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Fri, 28 Aug 2015 11:34:45 +0200
Message-ID: <55E02B35.7080006@ahsoftware.de>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <55B89C14.2070700@ahsoftware.de> <55BA1144.9090203@ahsoftware.de>
 <55CEEECA.8000702@ahsoftware.de> <55D1ACB8.3040500@ahsoftware.de>
 <20150828073429.GA67211@kafai-mba.gkf168.com>
 <55E02987.8040908@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E02987.8040908@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 28.08.2015 um 11:27 schrieb Alexander Holler:
> Am 28.08.2015 um 09:36 schrieb Martin KaFai Lau:
>> On Mon, Aug 17, 2015 at 11:43:20AM +0200, Alexander Holler wrote:
>>> That's why I vote to check out if it's possible/reasonable to
>>> backport this
>>> series to the stable kernels.
>> I have backported to 4.0.y without major issue, so possible.
>
> Sure, as this was likely one of the versions they've used to create the
> patch.
>
>> I did try on 3.1x and gave up.
>>
>> It is a lot of changes,  so I don't think it is a good idea for -stable.
>
> Depends on what you're expecting from a (stable) kernel.
>
> The patch description mentions what happens when a system deals with a
> lot of other ipv6-systems and that problem is easy to exercise and to
> value.
>
> Rating the information leak is harder, some people even won't understand
> that this might be a problem.
>
> And now look at which kernel-versions are now used in new devices
> (likely something <= 3.10, which is more than two years old), how long
> they will be used, and make a guess about IPv6 usage in 5 years.
>
> Anyway, I've no insights about all the politics happening in the
> background (e.g. stuff like the LTSI tree) and I've just wanted raise
> awareness about that (imho important) patch series.

Not to speak about phones, but those are most likely a problem of one 
specific company  ;)

Regards,

Alexander Holler

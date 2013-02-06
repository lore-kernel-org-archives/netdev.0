From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Wed, 06 Feb 2013 10:50:34 -0500
Message-ID: <51127BCA.7070900@mojatatu.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com> <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu> <511268F0.5070808@mojatatu.com> <5D4F2414-B869-46AA-B684-01F9EA88AD03@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5D4F2414-B869-46AA-B684-01F9EA88AD03@telecom-bretagne.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-02-06 09:39 AM, Emmanuel Thierry wrote:
>

> I think you misread the example !

I did ;->

> Marks are both 1, masks are different.
>
> This case is more complex than a policy
> with no mark (so mark=0 and mask=0) versus
> a policy with an exact mark (so mark=1 and mask=0xffffffff),
> and i wanted to know if the algorithm would take these kind of cases into account.
>

Aha. I think this is pushing the envelope a little - are there good use 
cases for this?
certainly you could insert with most exact mask first. No such check is 
made at the moment.

cheers,
jamal

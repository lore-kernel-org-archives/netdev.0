From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [TCP]: Fix truesize underflow
Date: Wed, 19 Apr 2006 23:29:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0604192329160.13738@bizon.gios.gov.pl>
References: <20060418123204.GA3962@gondor.apana.org.au>
 <20060418.132256.110004342.davem@davemloft.net> <20060418232713.GA11938@gondor.apana.org.au>
 <4445D305.8080505@kernelpanic.ru> <44466024.9040800@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-393972010-1145482191=:13738"
Cc: bb@kernelpanic.ru, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, kernel@linuxace.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:63717 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1751158AbWDSVbT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 17:31:19 -0400
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <44466024.9040800@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-393972010-1145482191=:13738
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 19 Apr 2006, Jesse Brandeburg wrote:

> Boris B. Zhmurov wrote:
>> Hello, Herbert Xu.
>>=20
>> On 19.04.2006 03:27 you said the following:
>>=20
>>> On Tue, Apr 18, 2006 at 01:22:56PM -0700, David S. Miller wrote:
>>>=20
>>>> I think it is deserving of some run time assertions, else these bugs
>>>> will elude us continually.  Luckily there are only a few places that
>>>> would need the run time assertion checks on skb->truesize, and I'll
>>>> try to spend a few cycles on implementing this soon.
>>>=20
>>>=20
>>> Yes indeed.  One place that comes to mind would be tcp_trim_head just
>>> before we munge truesize.
>>>=20
>>> Cheers,
>>=20
>>=20
>> I confirm, finally I don't see messages in dmesg about assertions. Nice=
=20
>> work :)
>>=20
> I can also confirm that both machines here had no problems after applying=
=20
> this patch. Good work!

Me too, me too. Thank you! :)

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-393972010-1145482191=:13738--

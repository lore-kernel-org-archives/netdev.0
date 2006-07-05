From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [e1000]:  flow control on by default - good idea really?
Date: Wed, 5 Jul 2006 22:37:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607052235080.12611@bizon.gios.gov.pl>
References: <1152033116.5276.22.camel@jzny2> <1152040839.5276.25.camel@jzny2>
 <44ABE79A.1060603@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-104785014-1152131838=:12611"
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	john.ronciak@intel.com, Ben Greear <greearb@candelatech.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:8426 "EHLO bizon.gios.gov.pl")
	by vger.kernel.org with ESMTP id S964853AbWGEUhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 16:37:54 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44ABE79A.1060603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-104785014-1152131838=:12611
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 5 Jul 2006, Auke Kok wrote:

> jamal wrote:
>> On Tue, 2006-04-07 at 13:11 -0400, jamal wrote:
>>> I have a device connected to a e1000 that was erroneously advertising
>>> both tx/rx flow control but wasnt properly reacting to it. The default=
=20
>>> setup on the e1000 has rx flow control turned on.
>>> I was sending at wire rate gige from the device - which is about
>>> 1.48Mpps. The e1000 was in turn sending me flow control packets
>>> as per default/expected behavior. Unfortunately, it was sending
>>> a very large amount of packets. At one point i was seeing upto
>>> 1Mpps and on average, the flow control packets were consuming
>>> 60-70% of the bandwidth. Even when i fixed this behavior to act
>>> properly, allowing flow control on consumed up to 15% of the bandwidth.=
=20
>>> Clearly, this is a bad thing. Yes, the device in the first instance was
>>> at fault. But i have argued in the past that NAPI does just fine withou=
t
>>> flow control being turned on, so even chewing 5% of bandwidth on flow
>>> control is a bad thing..
>>>=20
>>> As a compromise, can we declare flow control as an advanced feature
>>> and turn it off by default? People who feel it is valuable and know
>>> what they are doing can turn it off.
>>=20
>> I meant turn it on.
>>=20
>> BTW, As an addendum this default behavior changed around 2.6.16 it
>> seems.
>
> Flow Control is using the EEPROM provided value, the module driver itself=
=20
> does not choose a default:
>
> e1000_param.c:
>
> /* User Specified Flow Control Override
> *
> * Valid Range: 0-3
> *  - 0 - No Flow Control
> *  - 1 - Rx only, respond to PAUSE frames but do not generate them
> *  - 2 - Tx only, generate PAUSE frames but ignore them on receive
> *  - 3 - Full Flow Control Support
> *
> * Default Value: Read flow control settings from the EEPROM
> */
>
> Turning flow control off usually (i.e. almost always) causes (significant=
ly)=20
> _degraded_ performance. We should really leave it the way it is (as per=
=20
> eeprom setting), and this is best for most if not all people. The card it=
self=20
> has this value programmed, which makes it possible for the user to turn=
=20
> on/off flowcontrol per card consistently, which makes much more sense to =
me.=20
> Also considering e1000 hardware varies significantly.

I was never able to find such tool for Linux or at least DOS. Where should=
=20
I look for it?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-104785014-1152131838=:12611--

From: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Wed, 30 Nov 2011 05:16:48 -0700 (Mountain Standard Time)
Message-ID: <alpine.WNT.2.00.1111300514180.808@TSI>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop> <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com> <1322599991.2596.11.camel@edumazet-laptop>
 <alpine.WNT.2.00.1111291359290.1036@TSI> <1322601444.2596.21.camel@edumazet-laptop> <1322602283.2596.25.camel@edumazet-laptop> <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw@mail.gmail.com> <alpine.WNT.2.00.1111291815410.1288@TSI>
 <CAL1RGDWzVRc4jFtsKUC6FGrdAWn3_OThXpbChCETCR8UCrwDDA@mail.gmail.com> <alpine.WNT.2.00.1111292212280.208@TSI> <1322630768.2596.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="625875-18501-1322655409=:808"
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322630768.2596.64.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--625875-18501-1322655409=:808
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Wed, 30 Nov 2011, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 à 22:15 -0700, Marc Aurele La France a écrit :
>> On Tue, 29 Nov 2011, Roland Dreier wrote:
>>> On Tue, Nov 29, 2011 at 5:17 PM, Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org> wrote:
>>>> On Tue, 29 Nov 2011, Roland Dreier wrote:
>>>>> On Tue, Nov 29, 2011 at 1:31 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>>> wrote:
>>>>>> Here is the result of this audit, please double check and test it, I
>>>>>> only compiled this.

>>>>> Thanks Eric... I'll queue this up and send it on once we get a good
>>>>> report from Marc.

>>>> I can confirm that Eric's patch, retrofitted to 3.1.3, fixes the problem.

>>> Oh... the problem was already in 3.1?

>> Yes, but not in anything earlier.

> Yes :

> # git describe --contains f2c31e32b378a6653f
> v3.1-rc1~24^2~11

> It all depends if f2c31e32b378a6653f is backported to 3.0 someday, since
> it fixes bug added in commit f39925dbde778 (ipv4: Cache learned redirect
> information in inetpeer)

> # git describe --contains  f39925dbde778
> v2.6.39-rc1~468^2~349

http://www.spinics.net/lists/netdev/msg179639.html should also be 
considered for 3.1 stable as well, for the same reason.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
--625875-18501-1322655409=:808--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

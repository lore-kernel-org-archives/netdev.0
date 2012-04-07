From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option checking
Date: Sat, 7 Apr 2012 17:13:45 +0200
Message-ID: <CABe5r8Kygjg0O21Y5z-F=RRQCqT7ReNya+EohAJU1jauaK536Q@mail.gmail.com>
References: <1333795467-3643-1-git-send-email-eldad@fogrefinery.com>
	<20120407.084657.1719148601003380853.davem@davemloft.net>
	<CABe5r8KL=c1=emU_20ODwM5OvFJS9vaKV1ux2hSmGB5tmZoJ1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABe5r8KL=c1=emU_20ODwM5OvFJS9vaKV1ux2hSmGB5tmZoJ1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resend, previous message was [rightfully] rejected by the mailer)

On 7 April 2012 17:09, Eldad Zack <eldad@fogrefinery.com> wrote:
>
> On 7 April 2012 14:46, David Miller <davem@davemloft.net> wrote:
>>
>> From: Eldad Zack <eldad@fogrefinery.com>
>> Date: Sat, =A07 Apr 2012 12:44:27 +0200
>>
>> > Added strict checking of PadN, which can be used to increase heade=
r
>> > size and thus push the protocol header into the 2nd fragment.
>>
>> A sysctl _AND_ a kconfig option, give me a break, that's
>> pointless.
>>
>> Either we want this or we don't.
>
>
> You're right, that kconfig bit was silly.
> I'd like to keep the sysctl knob, though.
>
> Fixed patch follows.
>
> Eldad

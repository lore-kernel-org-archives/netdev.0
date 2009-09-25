From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Fri, 25 Sep 2009 21:50:11 +0200
Message-ID: <4ABD1EF3.7040400@upmc.fr>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090925131038.GA14778@ff.dom.local> <20090925134052.GA1661@linux-mips.org> <20090925183504.GA3307@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090925183504.GA3307@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

patch applied to 2.6.31.1 kernel keeping your other AX25 debugging patc=
hes.

So far, so good !

Thanks.

Bernard Pidoux


Jarek Poplawski a =E9crit :
> On Fri, Sep 25, 2009 at 02:40:52PM +0100, Ralf Baechle DL5RB wrote:
>> On Fri, Sep 25, 2009 at 01:10:38PM +0000, Jarek Poplawski wrote:
>>
>>> This bug isn't responsible for these oopses here, but looks quite
>>> obviously. (I'm not sure if it's easy to test/hit with the common
>>> tools.)
>> The issue your patch fixes is obvious enough.
>=20
> Yes, with new code there would be no doubt. But here, if you know it'=
s
> worked for some time, you wonder if you're not blind. |-)
>>> Jarek P.
>>> ------------>
>>> [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
>>>
>>> Use ax25_cb_put after ax25_find_cb in ax25_ctl_ioctl.
>>>
>>> Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
>>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> Reviewed-by: Ralf Baechle <ralf@linux-mips.org>
>>
> Thanks for reviewing,
> Jarek P.
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

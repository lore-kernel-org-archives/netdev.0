From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: Ethernet bug at Upstream-v3.15-rcx on Lager.
Date: Fri, 16 May 2014 14:56:07 +0900
Message-ID: <5375A877.1090606@renesas.com>
References: <53745E88.7040108@jinso.co.jp> <5374F753.70203@cogentembedded.com> <537564FC.4090905@jinso.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <linux-sh@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>
To: <cm-hiep@jinso.co.jp>, <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <537564FC.4090905@jinso.co.jp>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hiep-san,

(2014/05/16 10:08), =E3=82=AB=E3=82=AA=E3=80=80=E3=83=9F=E3=83=B3=E3=80=
=80=E3=83=92=E3=82=A7=E3=83=83=E3=83=97 wrote:
>>
>>> Please review it when you have time.
>>
>>    Please try this patch:
>>
>> http://marc.info/?l=3Dlinux-netdev&m=3D139602519809181
>>
> I have tested this patch on v3.15.0-rc5-00077-g14186fe, and results a=
re the message of
> "sh-eth r8a7790-ether eth0: Receive FIFO Overflow" has disappeared an=
d sending datagrams is good.
> (Bandwidth 10M to 100M: Test with 5/5 times by script and by hand are=
 good)
>=20

It's nice!
So, I hope the patch is merged in upstream.
However, the patch's change log mentioned r8a7790 only.
The r8a7791's ethernet controller also has this bit.

To Ben,

So, would you update your patch and resubmit it?

Best regards,
Yoshihiro Shimoda

From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Linux 2.6 Vs linux 2.4 routing
Date: Sat, 17 Jun 2006 12:33:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606171230490.19616@bizon.gios.gov.pl>
References: <d096a3ee0606161141n3c481ed9kfcbf70af7393affa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-476483786-1150540384=:19616"
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Mayuresh Chitale <mchitale@gmail.com>
In-Reply-To: <d096a3ee0606161141n3c481ed9kfcbf70af7393affa@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-476483786-1150540384=:19616
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 17 Jun 2006, Mayuresh Chitale wrote:

> Hi All,
Hi,

> I am doing a routing test using linux 2.4 and linux 2.6 kernel on our
> board. I am using 2.4.31 and 2.6.16.17 for comparison.
>
> I have ported the bsp and drivers from 2.4 to 2.6 and am using a
> smartbits tester which pumps traffic at high rates and at varying
> packet sizes.
>
> On 2.4, the test goes fine ie I get meaningful values. But on 2.6
> kernel, routing begins and continues for sometime before it completely
> stops. The smartbits configuration is identical in both the cases.
>
> I have noticed same problem with dlink and 3com cards which is causing
> me to suspect that there is some probem with 2.6 routing.
>
> Has anyone seen a similar problem ?
> Any inputs on this would be appreciated.

Did you enable IRQBALANCE in 2.6?

$ zcat /proc/config.gz |grep IRQBALANCE

If so, please try to disable it.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-476483786-1150540384=:19616--

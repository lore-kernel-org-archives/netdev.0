From: Hector Martin <hector@marcansoft.com>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe RLT-8139
 related)
Date: Thu, 05 Aug 2004 12:55:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41121237.4050305@marcansoft.com>
References: <Pine.LNX.4.44.0408041915510.14609-100000@silmu.st.jyu.fi> <41120882.40302@marcansoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Pasi Sjoholm <ptsjohol@cc.jyu.fi>, Francois Romieu <romieu@fr.zoreil.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org,
        netdev@oss.sgi.com, brad@brad-x.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Hector Martin <hector@marcansoft.com>
In-Reply-To: <41120882.40302@marcansoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hector Martin escribi=F3:

> Pasi Sjoholm wrote:
>
>> Ok, now I have tested it for 6 hours without crashing the driver. The=20
>> system's load has been something like 5-6 the whole time. I also made=20
>> some network load with ~90Mbps-incoming and ~90Mbps-outgoing traffic.
>> I haven't had time to test anything else but I'm quite sure that=20
>> there is no need for that anymore because the stability we have reache=
d.
>> I'll let you know if there's any problems within next few days but I=20
>> would recommend that those patches would be included in 2.6.8.=20
>> (without that "if (received > 0) {").
>>
>> Many thanks for your help to resolve this problem.
>> Hector, have you tested these patches?
>>
>> =20
>>
> Wow.. I gotta learn some more about kernel hacking someday.. lol
>
> I applied both (new) -10 and -20 patches and removed the test.
>
> I doubled the debug-messages that get sent to the PC (the UDP traffic)=20
> but it froze (the sender) and stopped sending them after 5 minutes. I=20
> guess that's because of the crappy TCP/IP stack on the other side=20
> (this is a PlayStation2 application i'm developing, and the homebrew=20
> PS2 TCP/IP stack doesn't have a good reputation.) I'm back to normal=20
> debugging, I'll test it for a couple of hours. So far, no problem.
> -
> To unsubscribe from this list: send the line "unsubscribe=20
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>
Ugh.. it stopped sending them again. Now I doubled them again and I'm=20
using a stabler TCP/IP stack. This one works OK. No problem so far...=20
anyway, even though it stopped and I had to restart the PS2 some times,=20
the PC has been receiving packets with no reboot whatsoever. I think=20
it's fixed :)

Now I have to tackle a completely different problem with TCP connections=20
on linux, but that's another story :)

From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 00:28:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407270021200.11416-100000@silmu.st.jyu.fi>
References: <20040726095505.2ddb3bec@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040726095505.2ddb3bec@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Jul 2004, Stephen Hemminger wrote:

>>>> I haven't been able to reproduce this with normal www-browsing or=20
>>>> ssh-connections but it's always reproducible when my eth0 is under h=
eavy=20
>>>> load.
>>> I guess it can be reproduced even if the binary (nvidia ?) module is =
never
>>> loaded after boot, right ?

>> After 24 hours of hard working I can answer yes to this question.=20
>> Now I can reproduce this from 2 to 15 minutes with 2 cp-processes from=
=20
>> samba->workstation->nfs, some software building with make -j 3, playin=
g=20
>> some mp3 via nfs to notice when kernel goes down.. =3D) and so on..

>> After that ksoftirqd takes almost all the cpu-time and the network is =
not=20
>> working at all.

> Is network traffic still coming in?=20

At least tcpdump doesn't say anything, I can only see only arp-packets=20
which my computer (not other computer's arp-packets) has made but no=20
response to those.

> or perhaps there is a network packet that causes some soft irq to go=20
> into an infinite loop. The recent iptables bug with ip options would be=
=20
> an example.

That would make sense but Robert Olsson had some knowledge of this and=20
said that this issue is probably the same that they have discussed in OSL.

--
Pasi Sj=F6holm

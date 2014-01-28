From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: How to identify 6to4 and 6in4 tunnels
Date: Tue, 28 Jan 2014 16:20:54 +0100
Message-ID: <52E7CAD6.4020500@6wind.com>
References: <52E63779.5090101@gmail.com> <52E65817.1090904@6wind.com> <52E75D23.10909@gmail.com> <52E75EA5.4070102@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E75EA5.4070102@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/01/2014 08:39, zhuyj a =E9crit :
> On 01/28/2014 03:32 PM, zhuyj wrote:
>> On 01/27/2014 08:59 PM, Nicolas Dichtel wrote:
>>> Le 27/01/2014 11:39, zhuyj a =E9crit :
>>>> Hi, Maintainers
>>>>
>>>> In our scene, we will create the 6in4/6to4 tunnel firstly and need=
 to check the
>>>> tunnel type, secondly, we will configure the ip address on it. So,=
 Could we
>>>> have
>>>> any way to get the actual tunnel for 6in4 and 6to4 from current li=
nux version?
>>>>
>>>> Both 6in4 and 6to4 have the same protocol =93IPPROTO_IPV6=94 in Li=
nux kernel. The
>>>> only difference is the ip address on the tunnel. Can we distinguis=
h them in
>>>> Linux kernel?
>>> Just check the prefix, like it is done in check_6rd().
>>>
>>>
>>> Regards,
>>> Nicolas
> Hi, Nicolas
> Thanks for your reply. Maybe I can configure 6to4 tunnel by the follo=
wing commands:
>
>   ip tunnel add tun6to4 mode sit remote any local 1.202.252.122 ttl 6=
4
>   ip link set dev tun6to4 up
>   ip -6 addr add 2002:01ca:fc7a::0012:0225:2122/128 dev tun6to4
>   ip -6 route add 2000::/3 via ::192.88.99.1 dev tun6to4 metric 1
>
> But the kernel can not identify the tunnel is 6to4 tunnel or 6in4 tun=
nel
> immediately. After the packets travel through this tunnel, the kernel=
 can
> identify the type of the tunnel by check_6rd.
>
> Is it right?
As soon as you have added the ipv6 addresses, you know that this tunnel=
 is a
6to4 tunnel.
But what problem are you trying to solve?


Regards,
Nicolas

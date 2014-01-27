From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: How to identify 6to4 and 6in4 tunnels
Date: Mon, 27 Jan 2014 13:59:03 +0100
Message-ID: <52E65817.1090904@6wind.com>
References: <52E63779.5090101@gmail.com>
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
In-Reply-To: <52E63779.5090101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 27/01/2014 11:39, zhuyj a =E9crit :
> Hi, Maintainers
>
> In our scene, we will create the 6in4/6to4 tunnel firstly and need to=
 check the
> tunnel type, secondly, we will configure the ip address on it. So, Co=
uld we have
> any way to get the actual tunnel for 6in4 and 6to4 from current linux=
 version?
>
> Both 6in4 and 6to4 have the same protocol =93IPPROTO_IPV6=94 in Linux=
 kernel. The
> only difference is the ip address on the tunnel. Can we distinguish t=
hem in
> Linux kernel?
Just check the prefix, like it is done in check_6rd().


Regards,
Nicolas

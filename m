From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.37 vlans on bnx2 not functional, panic with tcpdump
Date: Thu, 6 Jan 2011 15:52:21 -0800
Message-ID: <1294357941.21580.2.camel@HP1>
References: <4D2634DE.2060907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Iain Paton" <selsinork@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D2634DE.2060907@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2011-01-06 at 13:32 -0800, Iain Paton wrote:
> Hi,
> 
> vlans don't appear to be functional on my HP DL380G6 with onboard bnx2
> adapter using vanilla 2.6.37 kernel. No tagged vlan traffic 
> is arriving at the vlan interface.

VLANs on net-next-2.6 kernel works for me on bnx2 devices.  I'll try
2.6.37 next.

> 
> To reproduce, use vanilla 2.6.37 built with the attached config
> 
> ip link add link eth0 name v406 type vlan id 406
> ip link set up dev eth0
> ip link set up dev v406
> ip addr add 10.251.0.3/16 dev v406
> 
> from another machine on the same vlan run a ping to 10.251.0.3, ping
> returns destination host unreachable.
> 
> tcpdump -n -e -i v406  shows no traffic.
> 
> If I then run
> 
> tcpdump -n -e -i eth0
> 
> while the ping is still running I get
> 
> [  112.190114] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000008

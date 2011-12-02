From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BCM43224: 00:00:00:00:00:00 address
 (3.2.0-rc3-00099-g883381d)
Date: Fri, 2 Dec 2011 12:27:12 +0100
Message-ID: <4ED8B610.2010703@broadcom.com>
References: <20111201224851.GB20536@ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: "Nico Schottelius" <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111201224851.GB20536@ethz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2011 11:48 PM, Nico Schottelius wrote:
> Hello,
> 
> just received another version of the macbook air, which is
> labeled MacBookAir4,2 again.
> 
> This time I'm on Linus' 3.2.0-rc3-00099-g883381d and cannot
> use the integrated wifi:
> 
> [23:43] brief:drivers# ip l show wlan0 
> 2: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> [23:43] brief:drivers# ip l s wlan0 up
> RTNETLINK answers: Cannot assign requested address
> 
> It seems this time b43 is responsible for the card, not brcmsmac
> anymore (superseeded it seems).
> 
> Is there a working tree out there somewhere? :-)
> 
> Cheers,
> 
> Nico
> 

Hi Nico,

Have you tried the brcmsmac driver?

Gr. AvS

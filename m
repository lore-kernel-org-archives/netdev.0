From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: bfin_mac: enable VLAN support in Blackfin
 MAC driver
Date: Thu, 08 Jan 2009 11:30:09 -0800 (PST)
Message-ID: <20090108.113009.263402475.davem@davemloft.net>
References: <20090108.105531.176161465.davem@davemloft.net>
	<8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
	<8bd0f97a0901081105q1e897254kad9a8533b5845403@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooloney@kernel.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, graf.yang@analog.com
To: vapier.adi@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760863AbZAHTab@vger.kernel.org>
In-Reply-To: <8bd0f97a0901081105q1e897254kad9a8533b5845403@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mike Frysinger" <vapier.adi@gmail.com>
Date: Thu, 8 Jan 2009 14:05:33 -0500

> On Thu, Jan 8, 2009 at 14:01, Mike Frysinger wrote:
> > On Thu, Jan 8, 2009 at 13:55, David Miller wrote:
> >> We can get VLAN packets received and sent, using AF_PACKET
> >> sockets, for example.  The chip should still respect those
> >> even if VLAN proper is not being utilized.
> >
> > any tips on doing that ?
> 
> or rather, is there a driver or you two you can point out that is
> doing this correctly ?  the ones i looked at seemed to be doing it
> like the patch we posted ...

And I disagree with how those drivers are doing it :-)

At least the programming of the chip to accept all packet
types properly, VLAN or not, regardless of kernel config,
is definitely IMHO the way to go.

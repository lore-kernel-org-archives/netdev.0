From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH 2/2] netdev: bfin_mac: enable VLAN support in Blackfin MAC driver
Date: Thu, 8 Jan 2009 14:34:43 -0500
Message-ID: <8bd0f97a0901081134gc5b6eb9h7f20dea146fc6cd0@mail.gmail.com>
References: <20090108.105531.176161465.davem@davemloft.net>
	 <8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
	 <8bd0f97a0901081105q1e897254kad9a8533b5845403@mail.gmail.com>
	 <20090108.113009.263402475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: cooloney@kernel.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, graf.yang@analog.com
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759545AbZAHTe4@vger.kernel.org>
In-Reply-To: <20090108.113009.263402475.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 8, 2009 at 14:30, David Miller wrote:
> From: "Mike Frysinger" <vapier
>> On Thu, Jan 8, 2009 at 14:01, Mike Frysinger wrote:
>> > On Thu, Jan 8, 2009 at 13:55, David Miller wrote:
>> >> We can get VLAN packets received and sent, using AF_PACKET
>> >> sockets, for example.  The chip should still respect those
>> >> even if VLAN proper is not being utilized.
>> >
>> > any tips on doing that ?
>>
>> or rather, is there a driver or you two you can point out that is
>> doing this correctly ?  the ones i looked at seemed to be doing it
>> like the patch we posted ...
>
> And I disagree with how those drivers are doing it :-)
>
> At least the programming of the chip to accept all packet
> types properly, VLAN or not, regardless of kernel config,
> is definitely IMHO the way to go.

i know on our side we all agree with you, we just didnt (dont) know
any better ;)
-mike

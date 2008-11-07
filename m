From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 09:11:48 +0100 (CET)
Message-ID: <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com> <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se> <20081105.151015.206163697.davem@davemloft.net> <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-137064504-1710806521-1226044487=:10993"
Cc: David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---137064504-1710806521-1226044487=:10993
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15; FORMAT=flowed
Content-Transfer-Encoding: 8BIT

On Fri, 7 Nov 2008, Ilpo Järvinen wrote:

> On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:
>
>> On Wed, 5 Nov 2008, David Miller wrote:
>>
>>> This kind of thinking just perpetuates the problem forever.
>>
>> It's like the TCP option order "bug", where some devices would drop the
>> packets because of buggy implementations, that was changed in Linux to work
>> around others buggy code, and I see "ECN blackhole detection" as a similar
>> measure.
>
> That is entirely bogus claim! The different ordering of options cost us
> nothing, while disabling ECN certainly has an innumerable cost both in
> performance and in nobody taking the initiative which makes the situation
> worse for everybody.

I can't comment on "ECN blackhole detection" costing or costing none since 
I haven't been able to find the discussion between Alexey Kuznetsov and 
Sally Floyd that David Miller was referring to. Anything more to go on? A 
direct link to the thread would be great.

I have sent an email (which will hopefully initiate a discussion) to a 
mailinglist populated by a lot of the operational ISP community and asked 
around about ECN and views on that. I also checked around on core router 
platforms (Cisco 12000 and Cisco CRS-1, which definitely is two of the top 
three core router platforms deployed in the world) and it seems they do 
not support ECN as far as I can discern. This pretty much in the next 5 
year timeframe ECN widespread support in the major core ISP networks out 
of the question, leaving ECN support on the slower links where it might be 
deployed faster. I doubt it though.

> And about somebody earlier claiming that they'll get an impressions that
> Linux stack is broken (if such people even know that there's some network
> stack in Linux :-))... I'm rather sure those isp supports etc. put a blaim
> on us anyway even when loads of counterproof would exists because it's
> just cheaper to do nothing and blaim linux instead. Also some claims
> asserted by incompetent people easily start to live among random forums;
> an example from the previous incident: "since disabling timestamps helps,
> it must be that timestamps are broken" (and somebody even "more clueful"
> added that they got enabled for 2.6.27?!?), needless to say, neither
> holds.

People just want it to work, people disable IPv6 because their DNS servers 
don't respond properly to AAAA queries so they shut off IPv6 because they 
they just want everything to work, they don't want to understand.

Now, IPv6 for me is cruicial to the continuing life and prosperity of the 
Internet (NAT is bad). ECN is "nice to have".

But let me check out what the ISP community has to say before we get too 
upset, it might be that people agree and will start requesting ECN in the 
core equipment (I know I will) and then it might be worthwile after all.

I do see Linux (and Linux users) as leader(s) in deploying new technology, 
with ECN being one of them. Question is how much hurt we're going to take 
for it.

<http://www.merit.edu/mail.archives/nanog/msg12756.html> is a link to my 
email to the NANOG ML referenced above.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
---137064504-1710806521-1226044487=:10993--

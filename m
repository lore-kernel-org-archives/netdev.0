From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats	in	action	policer
Date: Tue, 21 Dec 2004 11:11:48 +0100
Message-ID: <41C7F6E4.1010507@trash.net>
References: <20041215130128.GK8493@postel.suug.ch>	 <1103119774.1077.74.camel@jzny.localdomain>  <41C05B60.6030504@trash.net>	 <1103484249.1046.143.camel@jzny.localdomain>  <41C6A6CC.1050105@trash.net> <1103552830.1049.355.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103552830.1049.355.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> I havent looked closely at tcng although Werner has showed it to me a
> few times (may be under influence). We need to pick one or other test
> setup. I dont care if its what I have, tcng or what Thomas has.
> I just stared quickly at what Thomas has and realize its not really
> automated. In my case it is easier because i can click on the proverbial
> one-button and run 20 tests (including a subset of the policer ones)
> and even capturing tcpdumps. I have attached a sample testcase. 
> They are harder to create and require the environment i have.
> But once you create them, you should be saying "go" - go do something
> and come back and get results.
> Whatever we end up having, my preference would be something along those
> lines,

tcsim has one major advantage, you can test the actual
scheduling algorithms for their behaviour under very
controlled conditions. It gave me a lot more confidence
when replacing the HFSC lists by rbtrees. But, as Thomas
notes, it does all its tests in userspace, which might
not be ideal for things besides scheduling algorithms.
So a combination of both seems to be best.

Regards
Patrick

From: Ben Greear <greearb@candelatech.com>
Subject: Re: Update on e1000 troubles (over-heating!) (problem solved)
Date: Tue, 08 Oct 2002 18:10:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA38214.9050607@candelatech.com>
References: <Pine.GSO.4.30.0210070753400.1861-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andre Hedrick <andre@pyxtechnologies.com>,
   linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> It does seem like you need a lot of packets over a period of time
> to recreate it. So if what you are trying to do can achieve that,
> you should reproduce it. How many connections and sessions can you
> support? BTW, does iscsi call for a zero-copy receive?

I ran it at top speed for 4+ hours today with no problems.  I was
actively cooling the cards with an extra p-IV cpu fan sitting
precariously on top of the cards.

So, my problems were definately heat related.  I have yet to try
to see if the same things makes the tg3 nics behave better, as
they ran even hotter than the e1000s.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

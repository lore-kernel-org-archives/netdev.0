From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Fri, 14 Jan 2005 15:00:20 -0600
Message-ID: <4D217F72-666F-11D9-8D70-000393C30512@freescale.com>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net> <20050113215808.GA15124@wohnheim.fh-wedel.de> <20050114010016.GA16635@gate.ebshome.net> <20050114145518.GA21418@wohnheim.fh-wedel.de>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050114145518.GA21418@wohnheim.fh-wedel.de>
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> In fact, we use different switch chips connected to PPC4xx directly.
>> In this situation, in my NAPI IBM EMAC driver I just have special
>> "PHY-less" case which is trivial "fixed settings" one. And all this
>> PHY lib is completely unneeded bloat.
>
> Wrt. the proposed PHY lib, I agree.  Didn't even bother to look at the
> code, it's mere size said enough.

Hmm... Before I spend too much time revising based on previous comments 
ebs made, is there a general consensus that the code is much too large? 
  I know there's a lot in there, but the goal is to simplify PHY 
management for all ethernet drivers, new and old, and thus reduce code 
size, overall.  Is this code heading in the right direction?  Does it 
do too much?  Too little?


Andy Fleming
Open Source Team
Freescale Semiconductor, Inc

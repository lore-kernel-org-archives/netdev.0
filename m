From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c TRY2
Date: Tue, 29 Mar 2005 09:33:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503290922580.4153@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro>
 <20050329012901.GL3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050329012901.GL3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Mar 2005, Thomas Graf wrote:

> * Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503290206500.3229@webhosting.rdsbv.ro> 2005-03-29 02:09
>> +	replay:
>> +	tcm = NLMSG_DATA(n);
>> +	tca = arg;
>> +	clid = tcm->tcm_parent;
>
> I know this has been in dave's patch already but why is this needed?

I checked a little and seems that this is not needed.
But I wonder why do we need to replay?
I see no reason for replay.
I follow the path and nothing is changing under us.
What I am missing?

Thank you!
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/

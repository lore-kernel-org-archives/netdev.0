From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI question
Date: Fri, 8 Nov 2002 20:50:43 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211082048300.16360-100000@shell.cyberus.ca>
References: <3DCC65CD.6060009@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCC65CD.6060009@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



This is basic Deficit Round Robin (DRR) algorithm, you cant just set
things arbitrarily, i am afraid ;->
Search for George Varghese's paper if you want to know more.

cheers,
jamal

On Fri, 8 Nov 2002, Ben Greear wrote:

> ###  How can quota ever get negative?  In other words, why not just
> set it to dev->weight always?  Or, if the dev didn't use up all it's
> quota from the last  round, why not
> ###  increase it up to a max of 2 x weight or something like that?
>
> 			if (dev->quota < 0)
>                                 dev->quota += dev->weight;
>                          else
>                                 dev->quota = dev->weight;
> 		} else {
> 			dev_put(dev);
> 			local_irq_disable();
> 		}
> 	}
>
>
> --
> Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
> President of Candela Technologies Inc      http://www.candelatech.com
> ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>
>
>

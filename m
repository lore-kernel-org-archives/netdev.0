From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c
Date: Tue, 29 Mar 2005 01:27:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503290126360.13715@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
 <20050328144701.GA3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328144701.GA3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005, Thomas Graf wrote:

> Looks good, except...
>> +				err = -EAGAIN;
>
> You're missing a goto err_out here, the ops == NULL won't catch it.
>
>> +			}
>>  		}
>>  	}
>>  #endif
>>
>> -	err = -EINVAL;
>>  	if (ops == NULL)
>>  		goto err_out;
>
> With the above goto inserted there is no need to move the err = -EINVAL.

Thanks, Thomas.

You are right.

I'm redoind the patch right now.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/

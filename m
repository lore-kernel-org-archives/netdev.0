From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 18:04:24 +0100
Message-ID: <42025998.5070704@rapidforum.com>
References: <4201A382.1020208@rapidforum.com> <20050202205437.571a702b@localhost.localdomain> <4201B4EA.2030101@rapidforum.com> <4201C9C5.1060002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4201C9C5.1060002@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several users complain about downloads stalling at 99% as well... I was unable to solve this issue.

Jeff Garzik wrote:
> Christian Schmid wrote:
> 
>> btw: Another problem I am experiencing is that downloads suddenly 
>> break in speed from 360 kb/sec to 8-12 kb/sec. 5 seconds later they 
>> stall completely. But the interesting part is, that the send-queue is 
>> completely full (checked with a grep in netstat). This looks like as 
>> if the receiver is just too slow. But this is not the case. That makes 
>> it rather funny. The receiver is waiting with an empty pipe but linux 
>> doesn't send. What could this be?
> 
> 
> 
> With recent kernels, I've noticed that my browser progress bar will 
> download about 98% of a page, then stall for several seconds, then 
> complete.
> 
> Very strange.  Haven't investigated it at all, though.
> 
>     Jeff
> 
> 
> 
> 

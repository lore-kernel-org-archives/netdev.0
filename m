From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: forcedeth 0.20 eth0: received interrupt report
Date: Mon, 12 Jan 2004 00:04:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001D671.6030008@gmx.net>
References: <200401112134.05375.berk@upnet.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stanislav Karchebny <berk@upnet.ru>
In-Reply-To: <200401112134.05375.berk@upnet.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stanislav Karchebny wrote:
> "eth0: received irq with unknown events 0x21. Please report"
> 
> This happens when i enable software CPU cooling on nForce2 chipset using 
> FVcool - this causes all nforce-net connections to fail miserably and these 
> events are generated in dmesg log.
> 
> The very moment i disable softcooling using fvcool -d the network resumes 
> normal operations.
> 
> Linux Kernel 2.6.0 final
> forcedeth 0.20
> ASUS A7N8X Deluxe mobo

Great! You're the first one finding out why this unknown event 0x01
happens. (0x20 is timer event)

Since another user saw the same message but wasn't able to get the network
running at all, I was stuck. Enabling normal receive doesn't help to get
rid of the error.

I know that nvnet is proprietary software and also not that stable
according to user reports, but could you perhaps try nvnet instead of
forcedeth?
If nvnet still works when you enable softcooling, I can try to add a
workaround to forcedeth so that it works, too.
If nvnet fails, I still can try a few tricks but I'd have to know more
than the nvnet driver writers about the nforce chipset and they are inside
nvidia and I don't even have any docs.


Thanks for your coperation,
Carl-Daniel

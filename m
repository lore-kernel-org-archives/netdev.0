From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH 2.4.28-rc1-bk3] forcedeth: Backport of gigabit ethernet
 support and media detection rewrite
Date: Sat, 30 Oct 2004 15:09:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41839292.7080305@colorfullife.com>
References: <Pine.LNX.4.44.0410301442220.25784-100000@dbl.q-ag.de> <20041030130011.GA4261@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, blazara@nvidia.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041030130011.GA4261@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>  
>
>>After applying this patch, the driver is nearly in sync with 2.6.10-rc1:
>>The only additional differences are __iomem annotations and the use of
>>netdev_priv.
>>    
>>
>
>Will __iomem and netdev_priv() changes be in a separate patch?
>
>2.4.x has both.
>
>  
>
Not now, they would appear in the next backport.
I'm backporting from a moving target. Two weeks ago I posted the patch 
for review to linux-netdev (based on a 2.6 -mm kernel). I haven't 
received any complaints, thus I'm submitting it now for merging.
During these two weeks the __iomem and netdev_priv change were added to 
2.6 and that causes the difference between my patch and 2.6.10-rc1.

--
    Manfred

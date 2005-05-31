From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] use mmiowb in tg3_poll
Date: Tue, 31 May 2005 08:53:42 -0400
Message-ID: <1117544022.6134.54.camel@localhost.localdomain>
References: <200410211628.06906.jbarnes@engr.sgi.com>
	 <Pine.LNX.4.33.0410221345400.392-100000@localhost.localdomain>
	 <20050528231209.GA8456@xi.wantstofly.org>
	 <Pine.LNX.4.61.0505300925570.11645@linux.site>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com,
        jesse.barnes@intel.com, gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0505300925570.11645@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-30-05 at 09:30 -0700, Arthur Kepner wrote:

> I quickly looked through the records that I have and, unfortunately, 
> wasn't able to locate raw data. But I found some scrawlings in my 
> notes which say the most recent measurements for an Altix are: 
> 
> 	i)  PIO read latency ~ 2.4 usec
> 	ii) mmiowb() latency ~ 1.1 usec
> 


In terms of CPU cycles, how many do the above compute to be?
The absolute time numbers you have are also useful for quantification
purposes.

Did i read correctly that your reads are about 2x more expensive than
the writes?

cheers,
jamal

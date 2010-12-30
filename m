From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Buffer-bloat (was Re: IPTV buffering)
Date: Thu, 30 Dec 2010 15:53:09 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1012301541550.10669@ask.diku.dk>
References: <20101216111843.88E16F0C32AB5@borg.medozas.de>
 <Pine.LNX.4.64.1012211634330.21593@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1012211634330.21593@ask.diku.dk>
Content-ID: <Pine.LNX.4.64.1012301541552.10669@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Dec 2010, Jesper Dangaard Brouer wrote:

>
> On Thu, 16 Dec 2010, Jan Engelhardt wrote:
>>  On Thursday 2010-12-16 10:57, Jesper Dangaard Brouer wrote:
>> 
>> >  [...] NetConf 2010, see:
>> > 
>> >  http://vger.kernel.org/netconf2010.html
>>
>>  I just went over a few slide sets, and noticed Dave's Netfilter summary
>>  about your IPTV talk, enlisting the point
>>
>>  * Ethernet switches buffer too small
>>
>>  ("too small".. "too few"?) Given the recent uproar about bufferbloat in
>>  routing devices (see LWN coverage about Getty's articles), wanting
>>  larger buffers seems to almost contradict what Getty would like.
>
> Always wanting small buffers doesn't make sense.  It seem that he is not 
> considering that network equipment can be used for other things than TCP/IP.

I have created a blogpost:
  http://netoptimizer.blogspot.com/2010/12/buffer-bloat-calculations.html

Where I explain how it makes sense to have small buffers on links with a 
small bandwidth.

  - ISPs need to adjust the buffer size according to the bandwidth of the 
link.


>>  Wanting more buffers vs. wanting less buffering seems to be quite
>>  contradictory. Jesper, what is your take on this?
>
> Skimming through Getty's blog post, I think Getty has actually missed what is 
> happening.  He should read my masters thesis[1]... The real problem is that 
> TCP/IP is clocked by the ACK packets, and on asymetric links (like ADSL and 
> DOCSIS), the ACK packets are simply comming downstream too fast on the larger 
> downstream link, resulting in bursts and high-latency on the upstream link.

Adjusting my statement; the asym ACK issue might be part the issue, 
causing the packets to queue in the buffer.

The buffer-bloat issue is very true and a real-life issue.  ISPs need to 
adjust the buffers according to the bandwidth on the link!

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------

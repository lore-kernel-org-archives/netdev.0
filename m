From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Tue, 23 Aug 2005 21:56:53 +0200
Message-ID: <17163.32645.202453.145416@robur.slu.se>
References: <20050815213855.GA17832@netnation.com>
	<43014E27.1070104@cosmosbay.com>
	<20050823190852.GA20794@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050823190852.GA20794@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Hello!

Simon Kirby writes:

 > I was under the impression, however, that the code Alexei added last time
 > I brought up this problem was intended to always allow gc when the the
 > table is full and another entry is attempting to be created, even when
 > under gc_min_interval.

 Yes your GC does not work at all in your 2.6 setups...Why?


 > rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 >  entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
 >         |        |     tot|        |      ed|    miss| verflow| _search|
 

 >   131062|      22|  125633|  125629|  125447|     182|     181|  837163|
 >   131062|       0|   13511|   13509|     900|   12609|   12609|      10|
 >   131062|       0|    8772|    8770|     600|    8170|    8170|       7|
 >   131062|       0|    8709|    8706|     600|    8106|    8106|       8|
 >   131062|       0|    8771|    8770|     600|    8170|    8170|       6|
 >   131062|       0|    8770|    8768|     600|    8168|    8168|       6|
 >   131062|       0|    8706|    8704|     600|    8104|    8104|      10|


 Can you try  
 
 echo 50 >  /proc/sys/net/ipv4/route/gc_min_interval_ms

 Cheers.
					--ro

From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Sun, 29 Jun 2003 09:45:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFE9921.5010902@drugphish.ch>
References: <Pine.LNX.4.44.0306290924310.28882-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Bellion and Thomas Heinz <nf@hipac.org>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0306290924310.28882-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

>>Apart from that Roberto Nibali did some preliminary testing on nf-hipac.
>>You can find his posting to linux-kernel here: 
>>http://marc.theaimsgroup.com/?l=linux-kernel&m=103358029605079&w=2
>>
>>Since there are currently no performance tests available for the
>>new release we want to encourage people interested in firewall
>>performance evaluation to include nf-hipac in their tests.
>  
> Yes, I had missed this when I quickly looked at the web page using lynx. 
> Thanks.
> 
> One obvious thing that's missing in your performance and Roberto's figures 
> is what *exactly* are the non-matching rules.  Ie. do they only match IP 
> address, a TCP port, or what? (TCP port matching is about a degree of 
> complexity more expensive with iptables, I recall.) 

When I did the tests I used a variant of following simple script [1].

There you can see that I only used a src port range. In an original 
paper I wrote for my company (announced here [2]) I did create rules 
that only matched IP addresses, the results were bad enough ;).

Meanwhile I should revise the paper as quite a few things have been 
addressed since then: For example the performance issues with OpenBSD 
packet filtering have mostly been squashed. I didn't continue on that 
matter because I fell severely ill last autumn and first had to take 
care of that.

[1] http://www.drugphish.ch/~ratz/genrules.sh
[2] http://www.ussg.iu.edu/hypermail/linux/kernel/0203.3/0847.html

HTH and Best regards,
Roberto Nibali, ratz
-- 
echo '[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq'|dc

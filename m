From: Ben Greear <greearb@candelatech.com>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Tue, 22 Oct 2002 09:56:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB5835B.8000502@candelatech.com>
References: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>	<3DB4EB25.5050706@candelatech.com> <15797.22728.683363.412344@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
> 
> 
>    In the help file, you suggest this at close:
>             for (i=0; i<NR_CPUS; i++) {
>  -                  if(adapter->cnt[i]) {
> .
>    I think the second if should probably be while, ie like this:
>             for (i=0; i<NR_CPUS; i++) {
>  +                  while(adapter->cnt[i]) {
>  
>  Thanks!
> 
>  Your postings about driver for p430 Phobos 4-port NIC was very confusing. 
>  I assume that tulip in 2.4.20-pre9 works even without the tulip-020922.pat.  
>  Right?

It works fine as far as negotiation and ping goes, it just drops packets
(and very rarely, locks up on receive) at higher speeds.  With NAPI and
larger receive buffers, it drops very few packets, though it does occasionally
lock up when I first start traffic.  I will run tulip-diag on it next time
it does this...

> 
>  Does the board have separate MII-transceivers or is the tulip chips used
>  for MII?

I'm not sure...

Thanks,
Ben

> 
>  Cheers.
> 
> 						--ro
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

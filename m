From: Ben Greear <greearb@candelatech.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 15:25:00 -0700
Message-ID: <42AA133C.2000009@candelatech.com>
References: <42A8E0FE.3020708@candelatech.com>	<1118361376.5838.20.camel@rh4>	<42A8EBDA.6010306@candelatech.com>	<1118363861.5838.29.camel@rh4>	<42AA016C.9050801@candelatech.com> <42AA0743.1020101@hp.com> <42AA0C9D.2060006@candelatech.com> <42AA0E17.8050201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42AA0E17.8050201@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> 
>> There will be a bridge chip, and indeed I see better performance when 
>> I just use a 2-port Intel NIC as opposed to a 4 port, even if I am 
>> only actively using 2 of the 4 ports on the 4-port NIC.  For the tg3 
>> hardware I only have a
>> 4-port NIC.  I do assume that a 2-port tg3 NIC w/out a bridge chip 
>> would be
>> faster..but probably not too much.
> 
> 
> I have been taught by several wise old engineers that the proper 
> spelling of assume is ass-u-me :)
> 
> Bridge chips can in theory do all sorts of nasty things to performance.

Sure...but the end result is that I need 2 port NICs and I need 4 port NICs.
The 4-port ones need a bridge, so I'm stuck with a bridge.  The Intel 4-port
with a bridge works OK, the tg3 not so good.  If someone else has a 2-port
BCM NIC that handles full line speed, then that would be a good data point,
but I'm unlikely to purchase one just to satisfy my curiousity.  If someone
wants to send me one, I'll happily stick it in my system and report the results.

>> I'm using FC2, basically a default install.  It does seem to have an irq
>> balance daemon running.  But, I'm not specifically binding IRQs or 
>> anything
>> like that.  pktgen tx is running as a single thread, so the rx code 
>> could run
>> mostly on the other CPU if locking allows...
> 
> again, never ass-u-me.

I'm not assuming anything here...just reporting the setup.

Truth is, the e1000 works really well for my application in most
configurations.  It was interesting for me to learn that
some folks are getting very good tg3 performance for TCP
transfers when the e1000 was dropping frames (see thread
from the last week or so).  So, I was a little supprised that
I did not see such good tg3 numbers.

If the answer is that the tg3 just can't do it, no shame there...but
if my testing can help the tg3 driver improve, I will try to do my
part.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Ben Greear <greearb@candelatech.com>
Subject: Re: 100 network limit
Date: Thu, 28 Aug 2003 14:46:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4E783F.6080707@candelatech.com>
References: <20030828180019.GH12541@krispykreme> <20030828210855.58759b69.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030828210855.58759b69.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Fri, 29 Aug 2003 04:00:19 +1000
> Anton Blanchard <anton@samba.org> wrote:
> 
> 
> 
>>Anyway as a short term fix Jamal suggested making a sysctl for this
>>maximum. If fixing this all properly is out of the question for 2.6,
>>would the sysctl approach be satisfactory? The other option is to just
>>bump the limit and recognise that the user is on his own if performance
>>sucks.
> 
> 
> You could just add a bitmap with a reasonable upper limit (1024?) and use 
> find_first_zero_bit()  I doubt doing that would be very intrusive.
> 
> -Andi

Since you can rename devices, that might not work.  A long time ago I
hashed the devices, both by name and by index...that gives good lookup performance, at least.  As for
create-time issues, that is definately slow path, and even searching linearly
4 or 8k devices is not a big deal (in my opinion).  So, why not make the hard-coded
100 limit be more like 8196 or something really large?  (It could still be adjustable
if needed.)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

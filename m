From: Steve Modica <modica@sgi.com>
Subject: High interrupt rate even when using NAPI
Date: Wed, 05 Nov 2003 12:03:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA93B82.5070508@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

I just noticed some strange behavior with the tg3 driver.

Even with NAPI enabled, during high loads of 1500 byte MTUS, I'm seeing a very 
high interrupt rate.  To move 500kBytes/sec I'm seeing 22k interrupts/sec.  It 
tracks very closely with the actualy throughput.

That amounts to about 1 interrupt per 23 bytes.  I figured with NAPI, we should 
do a lot better than that.

Is there a tuneable or some driver stat that I can track to figure out what's 
happening here?  I'd like to see that interrupt number be a lot lower.

Steve


-- 
Steve Modica
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me

From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 20:58:48 +0100
Message-ID: <42028278.7040008@rapidforum.com>
References: <4201A382.1020208@rapidforum.com>	<20050202205437.571a702b@localhost.localdomain>	<4201B4EA.2030101@rapidforum.com> <20050203113335.46396c11@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050203113335.46396c11@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hm how can I check that? and what do you mean with "board"? Mainboard? NIC? its an onboard-nic on 
this mainboard: http://www.supermicro.com/products/motherboard/Xeon/E7501/X5DP8-G2.cfm

The worst thing is the stalled downloads. It drops to 8-12 kb-sec. sometimes after a few seconds it 
goes up to full speed again, but sometimes it suddenly stops completely. After a few seconds it 
continues with full speed or it stalls forever. send-queue is always full.....

Thank you for your help in this matter.

Chris


Stephen Hemminger wrote:
> On Thu, 03 Feb 2005 06:21:46 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>Actually, thats my problem. Single streams are too slow! Before I had buffers up to 500 KB. This was 
>>very nice to CPU because I only needed to "push" more data once in 5 seconds. I am doing this every 
>>second now... *sigh* well maybe you might just want to add a /proc file in order to configure this 
>>behaviour.
>>
>>btw: Another problem I am experiencing is that downloads suddenly break in speed from 360 kb/sec to 
>>8-12 kb/sec. 5 seconds later they stall completely. But the interesting part is, that the send-queue 
>>is completely full (checked with a grep in netstat). This looks like as if the receiver is just too 
>>slow. But this is not the case. That makes it rather funny. The receiver is waiting with an empty 
>>pipe but linux doesn't send. What could this be?
>>
> 
> 
> Are you using a board that support TCP Segmentation Offload.  The problem may well be that
> before we were not doing congestion control properly with TSO.  A pre-2.6.8 host with TSO was violating
> all sorts of RFC's and unfairly monopolizing bandwidth.
> 

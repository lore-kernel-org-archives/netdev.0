From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Question] SMP for TCP/IP Stack
Date: Tue, 24 Sep 2002 20:11:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D912974.7010308@candelatech.com>
References: <20020925112731.A19934@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hyochang Nam <cannon@postech.ac.kr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hyochang Nam wrote:
> Can Linux Kernel 2.4.X handle two IP Packets at the same time
> in a SMP machine which has two CPUs?
> I have a SMP machine which equips two Intel Xeon CPUs and two
> Intel Gigabit Network Cards. When I sent small IP Packets
> to the machine, most of packets are dropped. When I watch 
> CPU utlization with TOP program, only one CPU shows high value
> but the other shows much low value, ie. 10% CPU utlization.
> My test shows current IP Stack in Linux Kernel cannot provide 
> SMP Processing properly. But, some articles said Linux Kernel 2.4
> gives true SMP processing. What do you think my problem is?
> 
> Best regards,
> 
> Hyochang Nam
> 

I will be interested to hear if your tests can generate heavy traffic
for more than a few hours...my machine keeps crashing when doing this
kind of test.

How many packets are you trying to send?

Also, try loading the NIC with TxDescriptors=4096 RxDescriptors=1024

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

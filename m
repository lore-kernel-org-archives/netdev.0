From: Ben Greear <greearb@candelatech.com>
Subject: probable bug in pktgen
Date: Tue, 12 Oct 2004 17:01:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416C706B.5030300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While testing my own pktgen code I noticed that I can cause spectacular
crashes by setting the 'multiskb' to > 1 and using VLAN interfaces.  I
believe this is because the virtual device changes the skb->dev pointer
when it xmits, and then pktgen tries to send exactly this pkt again,
even though the skb->dev is now hosed up.

Unfortunately, my patch will not do the kernel pktgen much good, but
next time someone is hacking there, maybe they can fix it :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

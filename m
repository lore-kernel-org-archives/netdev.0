From: Ben Greear <greearb@candelatech.com>
Subject: return values for hard_start_xmit and dev_queue_xmit
Date: Wed, 13 Oct 2004 11:34:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416D7526.8050206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While trying to get pktgen to effectively use VLANs to send traffic,
I noticed that the vlan code always returns 0 from it's hard_start_xmit
method.  Since it calls dev_queue_xmit inside that method, I tried
returning the value that dev_queue_xmit returns.  It seems that the
return values have different meanings because this causes crashes due
to freeing skbs when I shouldn't be...

The dev_queue_xmit method is fairly well documented in dev.c, but
there are zero comments in the netdevice.h file to explain what the
acceptable return values for hard_start_xmit are.

Does anyone know if there is a definative guide to the return values
for hard_start_xmit?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

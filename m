From: Ben Greear <greearb@candelatech.com>
Subject: setsockopt:  SO_PRIORITY and IP_TOS
Date: Thu, 03 Mar 2005 17:02:48 -0800
Message-ID: <4227B3B8.6060900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With regard to 2.6.11-rc4 (and probably others).

I just noticed something that struck me as a bit strange.
Might be per design though...

If you set the IP_TOS and then the SO_PRIORITY for a socket,
the TOS is what you set it to, and so is the priority.

However, if you set the PRIORITY (to 55, in my case)
and then set the IP_TOS (to 3, in my case), then the priority
will be re-set to 0.

My opinion is that setting the IP_TOS should not affect the priority,
especially if it has already been specifically set on that socket.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

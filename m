From: Ben Greear <greearb@candelatech.com>
Subject: [Fwd: dev_get_by_index is not hashed:  O(n)]
Date: Wed, 28 Aug 2002 00:33:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D6C7CC3.5040105@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear



-- Attached file included as plaintext by Ecartis --
-- File: dev_get_by_index is not hashed:  O(n)

Message-ID: <3D6C781B.8010506@candelatech.com>
Date: Wed, 28 Aug 2002 00:13:31 -0700
From: Ben Greear <greearb@candelatech.com>
Organization: Candela Technologies
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.1b) Gecko/20020722
X-Accept-Language: en-us, en
MIME-Version: 1.0
To: linux-net <linux-net@vger.kernel.org>
Subject: dev_get_by_index is not hashed:  O(n)
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I just noticed that dev_get_by_index is not hashed, it is just a linear
search through all interfaces.  This call is made in many places in the
kernel, and particularly in route.c

For machines with large numbers of interfaces (VLANs for instance),
this could be a real performance drag.

Any reason we don't keep interfaces in a hash-table by index?

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

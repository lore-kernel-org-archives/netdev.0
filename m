From: Ben Greear <greearb@candelatech.com>
Subject: NAPI-ized tulip patch against 2.4.20-rc1
Date: Tue, 05 Nov 2002 22:36:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC8B85B.5050805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a patch that makes Tulip support NAPI.  The vast bulk of these
changes come from Robert Olsson's ftp site, I just pieced them together.

It works good on my 4-port Tulip NICs, better than the default
driver at least (no, I never tried the old HW-Mitigation option).


This patch will also make use of Robert's skb-recycle patch if it's
been applied, but through #ifdef magic, it should also work w/out
that....

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

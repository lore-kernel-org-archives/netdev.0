From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: msleep changes
Date: Thu, 23 Sep 2004 05:24:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040923050120.0257f490@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Nish,
In latest BK :

# drivers/atm/lanai.c
# 2004/09/21 14:58:17-07:00 chas@cmf.nrl.navy.mil +1 -1
# [ATM]: [drivers] Use msleep() instead of schedule_timeout()
# From Nishanth Aravamudan <nacc@us.ibm.com>

diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2004-09-21 17:11:30 -07:00
+++ b/drivers/atm/lanai.c	2004-09-21 17:11:30 -07:00
@@ -813,7 +813,7 @@
  			DPRINTK("read, write = %d, %d\n", read, write);
  			break;
  		}
-		schedule_timeout(HZ / 25);
+		msleep(4);


??????

Just one that immediately lept to my eye.
I am not going to check them all.
That's your job :-)

These msleep(_interruptible) changes have been tested or ?

Margit

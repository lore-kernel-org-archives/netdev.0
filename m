From: "Jason Lunz" <lunz@reflexsecurity.com>
Subject: e1000 typo?
Date: Wed, 30 Jul 2003 13:21:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730172110.GA13929@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The diff between the 5.1.11 and the newest e1000 drivers has this hunk:

@@ -1999,7 +1996,7 @@
        }
 #else
        for(i = 0; i < E1000_MAX_INTR; i++)
-               if(!e1000_clean_rx_irq(adapter) &&
+               if(!e1000_clean_rx_irq(adapter) &
                   !e1000_clean_tx_irq(adapter))
                        break;
 #endif

is that intentional? I don't think it changes the code behavior, but it
doesn't look right.

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/

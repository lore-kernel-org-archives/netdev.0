From: cliff white <cliffw@osdl.org>
Subject: Constant errors with pktgen
Date: Mon, 14 Mar 2005 13:34:04 -0800
Message-ID: <20050314133404.2528647f@es175>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Robert.

I am doing some wrapper scripts for pktgen for some testing purposes.

My test rig is two machines with an e100 card, connected by crossover cable.

When i run pktgen, the error counter == packet count, always. 

Adding printk's, i see the error is coming from this bit past line 2688:
----------

                now = getCurUs();
                if (now > pkt_dev->next_tx_us) {
                        /* TODO: this code is slightly wonky.  */
                        pkt_dev->errors++;
                        pkt_dev->next_tx_us = now - pkt_dev->delay_us;
                        pkt_dev->next_tx_ns = 0;
                }
----------------
Any suggestions? More info if needed..
cliffw

-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman

From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: 2.6.7 tulip performance (with NAPI)
Date: Wed, 6 Oct 2004 21:21:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16740.17875.574967.11417@robur.slu.se>
References: <41633174.7070805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41633174.7070805@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > I tried setting the NICE level of pktgen to -10 and softirq to -18.  I
 > still see way more packets transmitted than received.

 If you have "max_before_softirq" in your version pktgen you can try it
 to balance your load. HZ=1000 in 2.6 can make scheduling different.


					      --ro
  

From: cranium 2003 <cranium.2003@gmail.com>
Subject: skbuff structure pointers
Date: Sun, 30 Jan 2005 18:41:06 +0530
Message-ID: <1d55641b05013005116295e61b@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
      By looking into skbuff.h it is clear that paket is stored in
skbuff structure which has
also many structures defined for each layer as union.
Can it be possible to retreive any structure by casting skb->data at
any stage once that struct is push to skbuff structure?
e.g. by looking in eth.c following statement tells it works but how???
struct ethhdr *eth = (struct ethhdr *)skb->data;
Also once a structure is assigned values/pushed it in skbuff structure
can it be possible to
change its values at any later stage?
e.g. in above ethernet case does it possible to change eth->h_proto in
ethernet driver file(8390.c)
regards,
cranium

From: Yan-Fa Li <yan@intruvert.com>
Subject: TG3 Performance Question
Date: Tue, 3 Dec 2002 12:30:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <D71BEAC27500D51199DF0002B328BA8D4FBEA2@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

I'm trying to figure out some performance issues I have with
the tg3 driver.

I'm trying to increase the performance of an existing test app, a simple
http simulator, by improving the hardware.  My original setup
uses dual 1.1GHz PIII systems on 64bit-66MHz PCI slots and Serverworks LE
chipsets.  The new setup is on AMD MPX2 systems with a single Athlon
2000MP.

Because of packet reordering issues, I have restricted my app to using
only a single CPU using the cpu affinity APIs.

On the serverworks systems I have DL2K network cards and am able
to sustain 400-450mbits of traffic per system pair using a NAPIzed
driver and a hacked up 2.4.19 kernel.

On the new AMD system I'm using a fresh 2.4.20 with a TG3 card.
The DL2K cards I have, have a chipset level incompatibility with
the AMD chipset which I believe has been fixed in the TG3 driver
and has only been fixed in hardware for the DL2K so I am unable
to test them in the AMD box.

Basically I am only able to get around the same performance with
a 1.6GHz Athlon than I can with a single 1.1GHz PIII.  This
perplexes me since I thought originally I was CPU bound.

Is this:

a) network card issue (i.e. the tg3 isn't as a well documented/
   tuned as the dl2k yet) ?
b) a PCI chipset issue, i.e. the AMD MPX is kinda lame, I've seen
   comments from Alan Cox that this may be so, especially vs
   the server works chipset.
c) 400-450mbits is the best you'll ever get with a single gigE
   card in a 64bit/66MHz PCI slot ?

I'm assuming that the tg3 and 2.4.20 kernels are both NAPI, looking
through the source code seems to indicate they are.  With the DL2K
driver I am able to specify tx and rx interrupt mitigation values.
Is there an equivalent for the tg3 ?  I can't see any useful
parameters using modinfo -p.

Any suggestions you might have to increase the performance
would be appreciated.  Right now I thinking about trying the following,
a) getting a new rev of DL2K that works with the AMD or b) switching
motherboards to Serverworks again.

Thanks

Yan


[[HTML alternate version deleted]]

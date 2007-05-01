From: =?ISO-8859-2?Q?Rafa=B3_Bilski?= <rafalbilski@interia.pl>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 01 May 2007 12:25:20 +0200
Message-ID: <46371590.4090004@interia.pl>
References: <46365887.3010705@interia.pl> <20070430205522.abad2481.akpm@linux-foundation.org> <20070501084639.GA528@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161699AbXEAKZg@vger.kernel.org>
In-Reply-To: <20070501084639.GA528@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> [...]=20
> Could you please run "ethtool -s eth0 msglvl 0xffffffff" to turn logg=
ing
> from the driver right up and send a log?  This will spam the log if
> there is any traffic but should say why the driver is doing this.
>=20
OK. Here it is. It is from 2.6.21.1 with Andrew patch applied. I had to=
=20
disable /var/log/messages because I have root fs on 1GB SD card. It is=20
output from dmesg command.
Btw. I've tried kexec, but it isn't working. I will have to flash kerne=
l=20
each time.

Thank You
Rafa=B3

eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 6 status was 0x98800076.
eth0: Transmit frame #4 queued in slot 3.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 7 status was 0x98800046.
eth0: tx frame #3 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 8 status was 0x98800076.
eth0: Transmit frame #5 queued in slot 4.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 9 status was 0x98800046.
eth0: tx frame #4 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 10 status was 0x98800076.
eth0: Transmit frame #6 queued in slot 5.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 11 status was 0x98800046.
eth0: tx frame #5 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 12 status was 0x98800076.
eth0: Transmit frame #7 queued in slot 6.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 13 status was 0x98800046.
eth0: tx frame #6 finished, status 0x8000072.
eth0: Transmit frame #8 queued in slot 7.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 14 status was 0x98800046.
eth0: tx frame #7 finished, status 0x8000242.
eth0: Transmit frame #9 queued in slot 8.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 15 status was 0x98800046.
eth0: tx frame #8 finished, status 0x8000072.
eth0: Media selection timer tick.
eth0: possible phy reset: re-initializing
eth0: Tx/Rx process stopped in 0 usec.
  Tx ring at c1189200:
 #0 desc. 0x1189210 0x8000072 0x13c405e.
 #1 desc. 0x1189220 0x8000072 0x134885e.
 #2 desc. 0x1189230 0x8000072 0x13d185e.
 #3 desc. 0x1189240 0x8000072 0x13be05e.
 #4 desc. 0x1189250 0x8000072 0x3bb05e.
 #5 desc. 0x1189260 0x8000072 0x139885e.
 #6 desc. 0x1189270 0x8000072 0x13ac05e.
 #7 desc. 0x1189280 0x8000242 0x139805e.
 #8 desc. 0x1189290 0x8000072 0xc6305e.
 #9 desc. 0x11892a0 0x000000 0x13b305e.
 #10 desc. 0x11892b0 0x000000 0x107965e.
 #11 desc. 0x11892c0 0x000000 0x13ed05e.
 #12 desc. 0x11892d0 0x000000 0x1b0585e.
 #13 desc. 0x11892e0 0x000000 0x13be05e.
 #14 desc. 0x11892f0 0x000000 0xc6785e.
 #15 desc. 0x1189200 0x000000 0x138a05e.
  Rx ring c1189000:
 #0 desc. 0x1189010 0x0005f2 0xc67810.
 #1 desc. 0x1189020 0x0005f2 0x13a0010.
 #2 desc. 0x1189030 0x0005f2 0x11d0010.
 #3 desc. 0x1189040 0x0005f2 0x13c4010.
 #4 desc. 0x1189050 0x0005f2 0x13b3010.
 #5 desc. 0x1189060 0x0005f2 0x13c4810.
 #6 desc. 0x1189070 0x0005f2 0x1377010.
 #7 desc. 0x1189080 0x0005f2 0x13d1810.
 #8 desc. 0x1189090 0x0005f2 0x1371010.
 #9 desc. 0x11890a0 0x0005f2 0x13be010.
 #10 desc. 0x11890b0 0x0005f2 0x1348010.
 #11 desc. 0x11890c0 0x0005f2 0x3bb010.
 #12 desc. 0x11890d0 0x0005f2 0x1b05810.
 #13 desc. 0x11890e0 0x0005f2 0x1398810.
 #14 desc. 0x11890f0 0x0005f2 0x13ac010.
 #15 desc. 0x1189100 0x0005f2 0x1398010.
 #16 desc. 0x1189110 0x0005f2 0x1442810.
 #17 desc. 0x1189120 0x0005f2 0x1371810.
 #18 desc. 0x1189130 0x0005f2 0x1351010.
 #19 desc. 0x1189140 0x0005f2 0x13ed810.
 #20 desc. 0x1189150 0x0005f2 0x1351810.
 #21 desc. 0x1189160 0x0005f2 0x1b05010.
 #22 desc. 0x1189170 0x0005f2 0x11d0810.
 #23 desc. 0x1189180 0x0005f2 0x1377810.
 #24 desc. 0x1189190 0x0005f2 0x13d9810.
 #25 desc. 0x11891a0 0x0005f2 0x13a0810.
 #26 desc. 0x11891b0 0x0005f2 0x1361810.
 #27 desc. 0x11891c0 0x0005f2 0x138a810.
 #28 desc. 0x11891d0 0x0005f2 0x1361010.
 #29 desc. 0x11891e0 0x0005f2 0x13f8810.
 #30 desc. 0x11891f0 0x0005f2 0x13f8010.
 #31 desc. 0x1189000 0x0005f2 0x136b810.
eth0: DSPCFG accepted after 0 usec.
eth0: Wake-up event 0x80000a
eth0: Setting full-duplex based on negotiated link capability.
eth0: Interrupt, status 0x002209, mask 0xf1cd65.
eth0: Poll, status 0x002209, mask 0xf1cd65.
  netdev_rx() entry 0 status was 0x98800076.
eth0: Transmit frame #1 queued in slot 0.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 1 status was 0x98800046.
eth0: tx frame #0 finished, status 0x8000082.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 2 status was 0x98800076.
eth0: Transmit frame #2 queued in slot 1.
eth0: Interrupt, status 0x000240, mask 0xf1cd65.
eth0: Poll, status 0x000240, mask 0xf1cd65.
eth0: tx frame #1 finished, status 0x8000072.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 3 status was 0x98800046.
eth0: Transmit frame #3 queued in slot 2.
eth0: Interrupt, status 0x000248, mask 0xf1cd65.
eth0: Poll, status 0x000248, mask 0xf1cd65.
eth0: tx frame #2 finished, status 0x8000242.
eth0: Poll, status 0x000001, mask 0xf1cd65.
  netdev_rx() entry 4 status was 0x98800046.
eth0: Transmit frame #4 queued in slot 3.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 5 status was 0x98800046.
eth0: tx frame #3 finished, status 0x8000072.
eth0: Media selection timer tick.
eth0: possible phy reset: re-initializing
eth0: Tx/Rx process stopped in 0 usec.
  Tx ring at c1189200:
 #0 desc. 0x1189210 0x8000082 0xc6785e.
 #1 desc. 0x1189220 0x8000072 0x10f905e.
 #2 desc. 0x1189230 0x8000242 0x134885e.
 #3 desc. 0x1189240 0x8000072 0xc7205e.
 #4 desc. 0x1189250 0x000000 0x3bb05e.
 #5 desc. 0x1189260 0x000000 0x139885e.
 #6 desc. 0x1189270 0x000000 0x13ac05e.
 #7 desc. 0x1189280 0x000000 0x139805e.
 #8 desc. 0x1189290 0x000000 0xc6305e.
 #9 desc. 0x11892a0 0x000000 0x13b305e.
 #10 desc. 0x11892b0 0x000000 0x107965e.
 #11 desc. 0x11892c0 0x000000 0x13ed05e.
 #12 desc. 0x11892d0 0x000000 0x1b0585e.
 #13 desc. 0x11892e0 0x000000 0x13be05e.
 #14 desc. 0x11892f0 0x000000 0xc6785e.
 #15 desc. 0x1189200 0x000000 0x138a05e.
  Rx ring c1189000:
 #0 desc. 0x1189010 0x0005f2 0xc63010.
 #1 desc. 0x1189020 0x0005f2 0x13ed010.
 #2 desc. 0x1189030 0x0005f2 0x138a010.
 #3 desc. 0x1189040 0x0005f2 0xc67810.
 #4 desc. 0x1189050 0x0005f2 0x10f9010.
 #5 desc. 0x1189060 0x0005f2 0x1348810.
 #6 desc. 0x1189070 0x0005f2 0x1377010.
 #7 desc. 0x1189080 0x0005f2 0x13d1810.
 #8 desc. 0x1189090 0x0005f2 0x1371010.
 #9 desc. 0x11890a0 0x0005f2 0x13be010.
 #10 desc. 0x11890b0 0x0005f2 0x1348010.
 #11 desc. 0x11890c0 0x0005f2 0x3bb010.
 #12 desc. 0x11890d0 0x0005f2 0x1b05810.
 #13 desc. 0x11890e0 0x0005f2 0x1398810.
 #14 desc. 0x11890f0 0x0005f2 0x13ac010.
 #15 desc. 0x1189100 0x0005f2 0x1398010.
 #16 desc. 0x1189110 0x0005f2 0x1442810.
 #17 desc. 0x1189120 0x0005f2 0x1371810.
 #18 desc. 0x1189130 0x0005f2 0x1351010.
 #19 desc. 0x1189140 0x0005f2 0x13ed810.
 #20 desc. 0x1189150 0x0005f2 0x1351810.
 #21 desc. 0x1189160 0x0005f2 0x1b05010.
 #22 desc. 0x1189170 0x0005f2 0x11d0810.
 #23 desc. 0x1189180 0x0005f2 0x1377810.
 #24 desc. 0x1189190 0x0005f2 0x13d9810.
 #25 desc. 0x11891a0 0x0005f2 0x13a0810.
 #26 desc. 0x11891b0 0x0005f2 0x1361810.
 #27 desc. 0x11891c0 0x0005f2 0x138a810.
 #28 desc. 0x11891d0 0x0005f2 0x1361010.
 #29 desc. 0x11891e0 0x0005f2 0x13f8810.
 #30 desc. 0x11891f0 0x0005f2 0x13f8010.
 #31 desc. 0x1189000 0x0005f2 0x136b810.
eth0: DSPCFG accepted after 0 usec.
eth0: Wake-up event 0x80000a
eth0: Setting full-duplex based on negotiated link capability.
eth0: Interrupt, status 0x002209, mask 0xf1cd65.
eth0: Poll, status 0x002209, mask 0xf1cd65.
  netdev_rx() entry 0 status was 0x98800076.
eth0: Transmit frame #1 queued in slot 0.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 1 status was 0x98800046.
eth0: tx frame #0 finished, status 0x8000082.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 2 status was 0x98800076.
eth0: Transmit frame #2 queued in slot 1.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 3 status was 0x98800046.
eth0: tx frame #1 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 4 status was 0x98800076.
eth0: Transmit frame #3 queued in slot 2.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 5 status was 0x98800046.
eth0: tx frame #2 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 6 status was 0x98800076.
eth0: Transmit frame #4 queued in slot 3.
eth0: Interrupt, status 0x000240, mask 0xf1cd65.
eth0: Poll, status 0x000240, mask 0xf1cd65.
eth0: tx frame #3 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 7 status was 0x98800076.
eth0: Transmit frame #5 queued in slot 4.
eth0: Interrupt, status 0x000240, mask 0xf1cd65.
eth0: Poll, status 0x000240, mask 0xf1cd65.
eth0: tx frame #4 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 8 status was 0x98800076.
eth0: Transmit frame #6 queued in slot 5.
eth0: Interrupt, status 0x000240, mask 0xf1cd65.
eth0: Poll, status 0x000240, mask 0xf1cd65.
eth0: tx frame #5 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 9 status was 0x98800046.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 10 status was 0x98800076.
eth0: Transmit frame #7 queued in slot 6.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 11 status was 0x98800046.
eth0: tx frame #6 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 12 status was 0x98800076.
eth0: Transmit frame #8 queued in slot 7.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 13 status was 0x98800046.
eth0: tx frame #7 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 14 status was 0x98800076.
eth0: Transmit frame #9 queued in slot 8.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 15 status was 0x98800046.
eth0: tx frame #8 finished, status 0x8000072.
eth0: Media selection timer tick.
eth0: possible phy reset: re-initializing
eth0: Tx/Rx process stopped in 0 usec.
  Tx ring at c1189200:
 #0 desc. 0x1189210 0x8000082 0xc6305e.
 #1 desc. 0x1189220 0x8000072 0x138a05e.
 #2 desc. 0x1189230 0x8000072 0x10f905e.
 #3 desc. 0x1189240 0x8000072 0x137705e.
 #4 desc. 0x1189250 0x8000072 0x13ed05e.
 #5 desc. 0x1189260 0x8000072 0x137105e.
 #6 desc. 0x1189270 0x8000072 0x134805e.
 #7 desc. 0x1189280 0x8000072 0x1b0585e.
 #8 desc. 0x1189290 0x8000072 0x13ac05e.
 #9 desc. 0x11892a0 0x000000 0x13b305e.
 #10 desc. 0x11892b0 0x000000 0x107965e.
 #11 desc. 0x11892c0 0x000000 0x13ed05e.
 #12 desc. 0x11892d0 0x000000 0x1b0585e.
 #13 desc. 0x11892e0 0x000000 0x13be05e.
 #14 desc. 0x11892f0 0x000000 0xc6785e.
 #15 desc. 0x1189200 0x000000 0x138a05e.
  Rx ring c1189000:
 #0 desc. 0x1189010 0x0005f2 0x13a0010.
 #1 desc. 0x1189020 0x0005f2 0x11d0010.
 #2 desc. 0x1189030 0x0005f2 0x13c4810.
 #3 desc. 0x1189040 0x0005f2 0xc72010.
 #4 desc. 0x1189050 0x0005f2 0x13b3010.
 #5 desc. 0x1189060 0x0005f2 0x138a010.
 #6 desc. 0x1189070 0x0005f2 0x13c4010.
 #7 desc. 0x1189080 0x0005f2 0x1377010.
 #8 desc. 0x1189090 0x0005f2 0x13ed010.
 #9 desc. 0x11890a0 0x0005f2 0x13be010.
 #10 desc. 0x11890b0 0x0005f2 0x10f9010.
 #11 desc. 0x11890c0 0x0005f2 0x1348810.
 #12 desc. 0x11890d0 0x0005f2 0x3bb010.
 #13 desc. 0x11890e0 0x0005f2 0xc67810.
 #14 desc. 0x11890f0 0x0005f2 0x1398810.
 #15 desc. 0x1189100 0x0005f2 0xc63010.
 #16 desc. 0x1189110 0x0005f2 0x1442810.
 #17 desc. 0x1189120 0x0005f2 0x1371810.
 #18 desc. 0x1189130 0x0005f2 0x1351010.
 #19 desc. 0x1189140 0x0005f2 0x13ed810.
 #20 desc. 0x1189150 0x0005f2 0x1351810.
 #21 desc. 0x1189160 0x0005f2 0x1b05010.
 #22 desc. 0x1189170 0x0005f2 0x11d0810.
 #23 desc. 0x1189180 0x0005f2 0x1377810.
 #24 desc. 0x1189190 0x0005f2 0x13d9810.
 #25 desc. 0x11891a0 0x0005f2 0x13a0810.
 #26 desc. 0x11891b0 0x0005f2 0x1361810.
 #27 desc. 0x11891c0 0x0005f2 0x138a810.
 #28 desc. 0x11891d0 0x0005f2 0x1361010.
 #29 desc. 0x11891e0 0x0005f2 0x13f8810.
 #30 desc. 0x11891f0 0x0005f2 0x13f8010.
 #31 desc. 0x1189000 0x0005f2 0x136b810.
eth0: DSPCFG accepted after 0 usec.
eth0: Wake-up event 0x80000a
eth0: Setting full-duplex based on negotiated link capability.
eth0: Interrupt, status 0x002209, mask 0xf1cd65.
eth0: Poll, status 0x002209, mask 0xf1cd65.
  netdev_rx() entry 0 status was 0x98800076.
eth0: Transmit frame #1 queued in slot 0.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 1 status was 0x98800046.
eth0: tx frame #0 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 2 status was 0x98800076.
eth0: Transmit frame #2 queued in slot 1.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 3 status was 0x98800046.
eth0: tx frame #1 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 4 status was 0x98800076.
eth0: Transmit frame #3 queued in slot 2.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 5 status was 0x98800046.
eth0: tx frame #2 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 6 status was 0x98800076.
eth0: Transmit frame #4 queued in slot 3.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 7 status was 0x98800046.
eth0: tx frame #3 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 8 status was 0x98800076.
eth0: Transmit frame #5 queued in slot 4.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 9 status was 0x98800046.
eth0: tx frame #4 finished, status 0x8000072.
eth0: Interrupt, status 0x000009, mask 0xf1cd65.
eth0: Poll, status 0x000009, mask 0xf1cd65.
  netdev_rx() entry 10 status was 0x98800076.
eth0: Transmit frame #6 queued in slot 5.
eth0: Interrupt, status 0x000249, mask 0xf1cd65.
eth0: Poll, status 0x000249, mask 0xf1cd65.
  netdev_rx() entry 11 status was 0x98800046.
eth0: tx frame #5 finished, status 0x8000072.


----------------------------------------------------------------------
Po meczu.....kurde...:)
>>> http://link.interia.pl/f1a72

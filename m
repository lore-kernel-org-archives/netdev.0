From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 9 Mar 2005 17:13:55 -0600
Message-ID: <200503091713.55454.jdmason@us.ibm.com>
References: <422F6C37.8090202@candelatech.com> <5fc59ff3050309140910f3e492@mail.gmail.com> <422F822D.9010707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <422F822D.9010707@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I don't see this problem at all on my 2.6.11-rc4-mm1 kernel (Athlon64 proc).

# ethtool -i eth0
driver: e1000
version: 5.7.6-k2
firmware-version: N/A
bus-info: 0000:00:07.0

# ethtool -d eth0
MAC Registers
-------------
0x00000: CTRL (Device control register)  0x00F00249
      Duplex:                            full
      Endian mode (buffers):             little
      Link reset:                        reset
      Set link up:                       1
      Invert Loss-Of-Signal:             no
      Receive flow control:              disabled
      Transmit flow control:             disabled
      VLAN mode:                         disabled
      Auto speed detect:                 disabled
      Speed select:                      1000Mb/s
      Force speed:                       no
      Force duplex:                      no
0x00008: STATUS (Device status register) 0x0000C343
      Duplex:                            full
      Link up:                           link config
      TBI mode:                          disabled
      Link speed:                        100Mb/s
      Bus type:                          PCI
      Bus speed:                         33MHz
      Bus width:                         32-bit
0x00100: RCTL (Receive control register) 0x00008002
      Receiver:                          enabled
      Store bad packets:                 disabled
      Unicast promiscuous:               disabled
      Multicast promiscuous:             disabled
      Long packet:                       disabled
      Descriptor minimum threshold size: 1/2
      Broadcast accept mode:             accept
      VLAN filter:                       disabled
      Cononical form indicator:          disabled
      Discard pause frames:              filtered
      Pass MAC control frames:           don't pass
      Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x00000003
0x02818: RDT   (Receive desc tail)       0x00000000
0x02820: RDTR  (Receive delay timer)     0x00000000
0x00400: TCTL (Transmit ctrl register)   0x000400FA
      Transmitter:                       enabled
      Pad short packets:                 enabled
      Software XOFF Transmission:        disabled
      Re-transmit on late collision:     disabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x000000D8
0x03818: TDT   (Transmit desc tail)      0x000000D8
0x03820: TIDV  (Transmit delay timer)    0x00000040
PHY type:                               M88

# uname -a
Linux victory 2.6.11-rc4-mm1 #4 Fri Feb 25 18:19:43 CST 2005 x86_64 AMD 
Athlon(tm) 64 Processor 3200+ AuthenticAMD GNU/Linux

On Wednesday 09 March 2005 05:09 pm, Ben Greear wrote:
> Ganesh Venkatesan wrote:
> > Ben:
> >
> > Are you using the e1000 that is included in the 2.6.11 kernel? ethtool
> > -d eth? works fine for me. What else is different in your env?
>
> I have patched the e1000 in my 2.6.11 kernel, but I see this -d problem
> on other un-patched systems as well, so it can't be (just) my patches
> that are the problem.
>
> I also tried this on my x86-64 opteron system, running FC3.  I
> have not hacked up this kernel or user-space tools at all :)
>
> [root@grok lanforge]# ethtool -i eth3
> driver: e1000
> version: 5.5.4-k2-NAPI
> firmware-version: N/A
> bus-info: 0000:02:08.0
> [root@grok lanforge]# ethtool -d eth3
> Cannot dump registers: Success
> [root@grok lanforge]# uname -a
> Linux grok 2.6.10-1.766_FC3smp #1 SMP Wed Feb 9 23:17:48 EST 2005 x86_64
> x86_64 x86_64 GNU/Linux
>
>
> I'm using ethtool 1.8 on this system.
>
>
> What version of ethtool are you using?

-- 
Jon Mason
jdmason@us.ibm.com

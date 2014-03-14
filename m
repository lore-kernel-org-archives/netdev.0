From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 10:37:34 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1403141036590.6461@gmail.com>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no> <20140313202557.GV3200@reaktio.net> <1394746907.15946.8.camel@dcbw.local> <20140313220812.GW3200@reaktio.net> <20140314075548.GX3200@reaktio.net> <87wqfxnppc.fsf@nemi.mork.no> <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no> <20140314090525.GB3200@reaktio.net> <87ob19nndo.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-683441087-389333343-1394789855=:6461"
Cc: =?ISO-8859-15?Q?Pasi_K=E4rkk=E4inen?= <pasik-X3B1VOXEql0@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ob19nndo.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---683441087-389333343-1394789855=:6461
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Yes, this is
the
solution, dfefinitively.


On Fri, 14 Mar 2014, Bjørn Mork wrote:

==Date: Fri, 14 Mar 2014 10:24:51
==From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
==To: Pasi Kärkkäinen <pasik-X3B1VOXEql0@public.gmane.org>
==Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
==Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
==
==Pasi Kärkkäinen <pasik-X3B1VOXEql0@public.gmane.org> writes:
==
==> # ifconfig wwp0s26u1u5i1
==> wwp0s26u1u5i1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
==>         inet 10.8.219.204  netmask 255.255.255.248  broadcast 10.8.219.207
==>         inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopeid 0x20<link>
==>         ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
==>         RX packets 0  bytes 0 (0.0 B)
==>         RX errors 1493  dropped 0  overruns 0  frame 0
==>
==> Note the RX errors.. ? 
==
==
==Yes, that is not expected and is quite possibly hiding the explanation.
==
==Could you do a usbmon dump to try to capture the contents of the USB
==buffers we drop here?  See
==https://www.kernel.org/doc/Documentation/usb/usbmon.txt
==
==Note that the text interface may truncate the buffers too early for the
==result to be useful.  wireshark/thsark will for example allow you to
==capture the whole buffer (when snooping on the "usbmonX" interface - not
==the netdev!)
==
==We also have a few debug messages in the driver for different types of
==errors we drop.  Turning on those might explain something (assuming you
==have DYNAMIC_DEBUG enabled):
==
==  ethtool -s wwp0s26u1u5i1 msglvl rx_err on
==
==Note that these will be logged at "debug" level, so you need to turn on
==logging/showing such messages as well.
==
==
==
==Bjørn
==
---683441087-389333343-1394789855=:6461--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

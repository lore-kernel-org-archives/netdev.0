From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Tue, 29 Aug 2017 23:32:58 +0200
Message-ID: <201708292332.58569.linux@rainbow-software.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org> <20170828.164208.1908438929113102094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, samuel@sortiz.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828.164208.1908438929113102094.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 29 August 2017 01:42:08 David Miller wrote:
> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date: Sun, 27 Aug 2017 17:03:30 +0200
>
> > The IRDA code has long been obsolete and broken.  So, to keep people
> > from trying to use it, and to prevent people from having to maintain it,
> > let's move it to drivers/staging/ so that we can delete it entirely from
> > the kernel in a few releases.
>
> No objection, I'll apply this to net-next, thanks Greg.

IRDA works fine in Debian 9 (kernel 4.9) and I use it for simple file 
transfer. Hope I'm not the only one...

# irattach /dev/ttyS0 -d tekram -s
# irdadump
21:28:52.830350 xid:cmd aed8eb79 > ffffffff S=6 s=0 (14)
21:28:52.922368 xid:cmd aed8eb79 > ffffffff S=6 s=1 (14)
21:28:53.014350 xid:cmd aed8eb79 > ffffffff S=6 s=2 (14)
21:28:53.106338 xid:cmd aed8eb79 > ffffffff S=6 s=3 (14)
21:28:53.190276 xid:rsp aed8eb79 < 000035d1 S=6 s=3 Nokia 6230i hint=b125 [ 
PnP Modem Fax Telephony IrCOMM IrOBEX ] (28)
21:28:53.198384 xid:cmd aed8eb79 > ffffffff S=6 s=4 (14)
21:28:53.290382 xid:cmd aed8eb79 > ffffffff S=6 s=5 (14)
21:28:53.382341 xid:cmd aed8eb79 > ffffffff S=6 s=* pentium hint=0400 [ 
Computer ] (23)
^C
8 packets received by filter

$ obexftp -i -l MMC
Connecting..\done
Receiving "MMC".../<?xml version="1.0"?>
<!DOCTYPE folder-listing SYSTEM "obex-folder-listing.dtd"
 [ <!ATTLIST folder mem-type CDATA #IMPLIED> ]>
<folder-listing version="1.0">
    <parent-folder />
    <file name="Image000.jpg" size="304300" modified="20160219T135924" 
user-perm="RWD"/>
    <file name="Image001.jpg" size="270037" modified="20170811T233122" 
user-perm="RWD"/>
    <file name="Image004.jpg" size="53519" modified="20170814T074550" 
user-perm="RWD"/>
....
$ obexftp -i -c MMC -g Image004.jpg
Connecting..\done
Sending "MMC"...|done
Receiving "Image004.jpg"...-done
Disconnecting..\done


-- 
Ondrej Zary

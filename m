From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH]Add device drivers (GbE, Packet Hub) for Topcliff
Date: Mon, 19 Apr 2010 21:34:26 +0900
Message-ID: <002301cadfbc$ab2e1490$66f8800a@maildom.okisemi.com>
References: <000b01cadd4c$e2f94380$66f8800a@maildom.okisemi.com> <20100416083508.64199657@tpl.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>
To: "Jonathan Corbet" <corbet@lwn.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi jon,
Thanks for your suggestion again.
I joined the netdev and send my patch to "netdev <netdev@vger.kernel.org>".

--
Hello netdev users,

I developed the device drivers for Linux kernel 2.6.33-1.
This time, I added the following drivers
  - GbE device
  - Packet HUB device

The GbE and Packet Hub device drivers are related with each other.
Because I send patch to LKML <linux-kernel@vger.kernel.org> and the netdev
<netdev@vger.kernel.org> mailing list.

Would you check them?

The patch is uploaded to our WEB site in Sourceforge.net,
Because the patch size was large.

[Our WEB site in Sourceforge.net.]
http://sourceforge.net/projects/generalembedded/files/
"All Files" -> "Downloads" -> "Dev" -> "kernel 2.6.33-1"
  - pch_gbe.patch  (for GbE device)
  - pch_phub.patch (for Packet HUB device)


[About our development product]
Topcliff is a chip that has many peripherals.
The chip has UART, I2C, SPI, IEEE1588, CAN, Packet HUB, SATA, USB host, USB
device, SDIO, Gigabit Ethernet, GPIO and DMA.

Best regards,
Masayuki Ohtake <masa-korg@dsn.okisemi.com>
----- Original Message ----- 
From: "Jonathan Corbet" <corbet@lwn.net>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Cc: "LKML" <linux-kernel@vger.kernel.org>; "Intel OTC"
<joel.clark@intel.com>; <andrew.chih.howe.khor@intel.com>
Sent: Friday, April 16, 2010 11:35 PM
Subject: Re: [PATCH]Add device drivers (GbE, Packet Hub) for Topcliff


> On Fri, 16 Apr 2010 19:09:04 +0900
> "Masayuki Ohtake" <masa-korg@dsn.okisemi.com> wrote:
>
> > I developed the device drivers for Linux kernel 2.6.33-1.
> > This time, I added the following drivers
> >   - GbE device
> >   - Packet HUB device
> >
> > Would you check them?
>
> Thanks for making your code available.  May I suggest, though, that you
> will get a much better response if you post the patches directly to the
> mailing list?  That is how our process works; it is simply harder to
> review code if you have to do digging through web sites to find it.
>
> Networking-specific patches should be posted to the netdev list as well.
>
> More information on how to post code for review can be found in the
> kernel source tree:
>
> Documentation/HOWTO
> Documentation/development-process
>
> Thanks,
>
> jon
>

From: "Joseph Chang" <joseph_chang@davicom.com.tw>
Subject: RE: [PATCH 1/1] net: add dm9620 net usb driver
Date: Wed, 3 Jul 2013 13:49:11 +0800
Message-ID: <201307030548.r635mxI6027578@mail.davicom.com.tw>
References: <87mwqglhqj.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Greg Kroah-Hartman'" <gregkh@linuxfoundation.org>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>, <joseph_chang@davicom.com.tw>,
	<josright@hotmail.com>
To: "'Peter Korsgaard'" <jacmet@sunsite.dk>,
	"'Joseph CHANG'" <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mwqglhqj.fsf@dell.be.48ers.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Peter,

  This is Joseph CHANG, I am glade to contact and work with you.
  I am busy in some affairs else these days, and will like to be back soon.

  For the begin, We copy the source code 'dm9601.c' which was by you,
   In order to work for our new chips (DM9620, DM9621, DM9621A... series),
   We did modify to get 'dm9620.c' base on 'dm0601.c',
   Since you are the author and also the owner, so keep MODULE_AUTHOR() as you.

  To generate DM9620.c is a way to distinguish the different generation chips:
(as below)

   DM9601: old revision:     USB1.1, Ethernet 10/100,     Phase out
   DM9620: current revision:  USB2.0, Ethernet 10/100,     Mass production state
   DM9633: next revision:    USB3.0, Ethernet 10/100/1000, Will to release on
2013/E

  So want to make it from the configuration by "make menuconfig".

  Can you help give further advices, we hope you can go ahead be the owner
(author) of the 
  'dm9620.c', And then we make patch to it. Would you agree this idea? If so we
will be happy
  because we did not ever create such a code.

  * Think about DM9633 driver to be, It will be is total different compare to
DM9601 & 
    DM9620. And will get the same issue.
 
ThankYou and Best Regards,
Joseph CHANG 
System Application Engineering Division 
Davicom Semiconductor, Inc. 
No. 6 Li-Hsin Rd. VI, Science-Based Park, 
Hsin-Chu, Taiwan. 
Tel: 886-3-5798797 Ex 8534
Fax: 886-3-5646929 
Web: http://www.davicom.com.tw 


-----Original Message-----
From: Peter Korsgaard [mailto:jacmet@gmail.com] On Behalf Of Peter Korsgaard
Sent: Monday, June 24, 2013 4:01 AM
To: Joseph CHANG
Cc: Greg Kroah-Hartman; linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org;
netdev@vger.kernel.org; joseph_chang@davicom.com.tw; josright@hotmail.com
Subject: Re: [PATCH 1/1] net: add dm9620 net usb driver

>>>>> "Joseph" == Joseph CHANG <josright123@gmail.com> writes:

 Joseph> DM9620 is an USB2.0 network adapter rather than DM9601 USB1.1. This
 Joseph> driver processed the RX data 4 bytes header, TX data 2 bytes header,
 Joseph> make the control bit exactly right in PHY write function, and optional
 Joseph> IFF_ALLMUTLI bit for RX control.

But dm9601.c already supports the dm9620 based devices. Why another
driver for the same hardware?

Please CC me on dm9601 related patches.

 Joseph> Tested good for many platforms, include X86 desktop and ARM embedded.

 Joseph> +static struct usb_driver dm9620_driver = {
 Joseph> +	.name = "dm9620",
 Joseph> +	.id_table = products,
 Joseph> +	.probe = usbnet_probe,
 Joseph> +	.disconnect = usbnet_disconnect,
 Joseph> +	.suspend = usbnet_suspend,
 Joseph> +	.resume = usbnet_resume,
 Joseph> +	.disable_hub_initiated_lpm = 1,
 Joseph> +};
 Joseph> +
 Joseph> +module_usb_driver(dm9620_driver);
 Joseph> +
 Joseph> +MODULE_AUTHOR("Peter Korsgaard <jacmet@sunsite.dk>");

I'm not the author of this file.


-- 
Bye, Peter Korsgaard

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

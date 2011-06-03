From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 3 Jun 2011 12:23:21 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B620@EXDCVYMBSTM006.EQ1STM.local>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
 <5203.1307062683@turing-police.cc.vt.edu>
 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B5F2@EXDCVYMBSTM006.EQ1STM.local>
 <201106031201.21933.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	Dan Williams <dcbw@redhat.com>,
	Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201106031201.21933.oneukum@suse.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum@suse.de]
> Sent: Friday, June 03, 2011 12:01 PM
> 
> This is not ideal. Distributions cannot care about every VIP:PID value.
> If a device with an NCM interface needs to be treated in a special
> manner we'd better have a special name for such interfaces.

There is no difference between cdc_ncm and cdc_ether devices, besides
the fact cdc_ncm is more efficient in data transfer and cpu load.
The problem is that you cannot say much about device functionality based
just on interface name. As example existing devices with cdc_ether 
interface could be mobile phone which provides connectivity to 3G network,
or could be a phone in the mode "over PC", where phone applications
access internet via broadband connection on PC (to save money).

Network manager cannot simply make decision which devices can be used
for mobile broadband access based on interface name. It needs an additional
info, which does not exist in device descriptor. 

So, back to original question, is there any point to rename an interface name,
if it can't be guaranteed that any device would be wwan device?

/alexey

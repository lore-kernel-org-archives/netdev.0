From: Dan Williams <dcbw@redhat.com>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Thu, 02 Jun 2011 17:29:02 -0500
Message-ID: <1307053743.21633.22.camel@dcbw.foobar.com>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
	 <1306922913-17803-2-git-send-email-metze@samba.org>
	 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-06-01 at 12:20 +0200, Alexey ORISHKO wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Stefan Metzmacher
> > Sent: Wednesday, June 01, 2011 12:09 PM
> 
> 
> > -	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
> > +	.flags = FLAG_WWAN | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
> 
> This patch will introduce incompatibility with already existing
> applications, which track usbX devices. As a result, end user
> application will stop working.

Applications should *never* track devices based solely on a device name
prefix.  What do they do when the device gets renamed either by udev
rules or the user?  It's simply broken.  Device names are not stable API
and they can and do change at will.  Applications that expect them to
have a stable prefix are simply broken.

Dan

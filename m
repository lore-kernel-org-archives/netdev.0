From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: Aw: Re: [PATCH 0/5] HID: roccat: Achieve userspace notification on
 sysfs attribute creation
Date: Thu, 9 Dec 2010 14:44:06 +0100 (CET)
Message-ID: <2069123096.22885.1291902246397.JavaMail.ngmail@webmail07.arcor-online.net>
References: <alpine.LNX.2.00.1012091430130.508@pobox.suse.cz> <1290801444.18750.161.camel@neuromancer>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, gregkh@suse.de, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: jkosina@suse.cz, erazor_de@users.sourceforge.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012091430130.508@pobox.suse.cz>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 


----- Original Nachricht ----
Von:     Jiri Kosina <jkosina@suse.cz>
An:      Stefan Achatz <erazor_de@users.sourceforge.net>
Datum:   09.12.2010 14:30
Betreff: Re: [PATCH 0/5] HID: roccat: Achieve userspace notification on sysfs
 attribute creation

> On Fri, 26 Nov 2010, Stefan Achatz wrote:
> 
> > Adding sysfs attributes to an already created device raises no userland
> > notification.
> > 
> > Instead of fiddling around in the depths of busses and devices I reuse
> the
> > event char device (module hid-roccat). This device gets now created with
> > a hardware specific class that contains the device attributes.
> 
> Hi Stefan,
> 
> I have applied the series, and removed the #pragma pack ugliness. Thanks,

Hello Jiri,
Using my patch replacing the #pragma pack with the __packed macro would have saved you some time:
https://lkml.org/lkml/2010/11/27/14

Just for the future: Whats better using the verbose version __attribute__ ((__packed__)) or the macro
__packed as I did?

Thanks, Stefan

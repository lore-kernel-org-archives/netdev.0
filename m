From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: Tigon 3 driver & Netgear GA302T
Date: 24 Apr 2002 11:21:59 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <m3662hnmug.fsf@trained-monkey.org>
References: <Mutt.LNX.4.44.0204250109340.11191-100000@blackbird.intercode.com.au>
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: James Morris's message of "Thu, 25 Apr 2002 01:15:06 +1000 (EST)"
List-Id: netdev.vger.kernel.org

>>>>> "James" == James Morris <jmorris@intercode.com.au> writes:

James> Does the tg3 driver support the Netgear GA302T card (which I
James> think uses the Altima AC1000 chip) ?

If it's the Altima then I guess so, otherwise I'd expect the 83820
driver to run it.

>From the list of devices for tg3:

#ifndef PCI_VENDOR_ID_ALTIMA
#define PCI_VENDOR_ID_ALTIMA		0x173b
#define PCI_DEVICE_ID_ALTIMA_AC1000	0x03e8
#endif

Jes

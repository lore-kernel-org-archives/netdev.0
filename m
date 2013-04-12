From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Fw: [Bug 56521] New: No support of Motorola ZN5 USBnet in zaurus
 module
Date: Fri, 12 Apr 2013 08:32:59 -0700
Message-ID: <20130412083259.13e7905e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 12 Apr 2013 07:27:18 -0700
From: "bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org" <bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>
To: "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [Bug 56521] New: No support of Motorola ZN5 USBnet in zaurus module


https://bugzilla.kernel.org/show_bug.cgi?id=56521

           Summary: No support of Motorola ZN5 USBnet in zaurus module
           Product: Networking
           Version: 2.5
    Kernel Version: 3.7.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
        ReportedBy: a1ba.omarov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
        Regression: No


Created an attachment (id=98391)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=98391)
zaurus.patch

I've tried to plug my phone via USBnet, but zaurus module is not loaded,
because kernel can't detect it as zaurus-like device.

I looked to dmesg and found that:

[ 7880.799111] usb 1-1: new high-speed USB device number 5 using ehci_hcd
[ 7880.957767] usb 1-1: New USB device found, idVendor=22b8, idProduct=6424
[ 7880.957771] usb 1-1: New USB device strings: Mfr=3, Product=2,
SerialNumber=0
[ 7880.957774] usb 1-1: Product: ZN5
[ 7880.957777] usb 1-1: Manufacturer: Motorola Inc.
[ 7881.646079] usb 1-1: bad CDC descriptors
[ 7881.646100] usbcore: registered new interface driver cdc_ether

In source file I don't found my idProduct=6424, but found support of Motorola
MOTOMAGX Phones with idProduct=6425

I added in drivers/net/usb/zaurus.c idProduct of my phone and it works
perfectly and without any errors or warnings. 

Attachment contains patch for zaurus.c. Please, add it to kernel. 

P.S. Sorry for my English, I know it bad. =(

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

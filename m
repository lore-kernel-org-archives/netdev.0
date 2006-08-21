From: Jon Wikne <wikne@cheetah.uio.no>
Subject: sky2 driver - large files upload problem
Date: Mon, 21 Aug 2006 14:41:04 +0200
Message-ID: <44E9A9E0.20106@cheetah.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.4]:28114 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S1751860AbWHUMlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 08:41:10 -0400
Received: from mail-mx2.uio.no ([129.240.10.30])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1GF95Y-0003hU-Ha
	for netdev@vger.kernel.org; Mon, 21 Aug 2006 14:41:08 +0200
Received: from pat.uio.no ([129.240.10.4])
	by mail-mx2.uio.no with esmtp (Exim 4.43)
	id 1GF95W-0005NQ-8g
	for netdev@vger.kernel.org; Mon, 21 Aug 2006 14:41:06 +0200
Received: from cheetah.uio.no ([129.240.84.96])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1GF95V-0003h8-Il
	for netdev@vger.kernel.org; Mon, 21 Aug 2006 14:41:05 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen & rest of list,

I'm having a peculiar problem with the sky2 driver.
The problem is seen on the versions in kernels 2.6.16.16,
2.6.17.8 and 2.6.18-rc4.

The problem appears when uploading large files (for instance
via scp) _from_ the system in question. Downloads work OK,
as does normal interactive traffic against the remote system.

What happens is typically this: After transeferring some
data, ranging from less than 100kB to 10MB, the upload freezes,
i.e. gets no further. Use of ping shows the connection is
effectively dead. If I do a sequence /sbin/ifdown eth0
/sbin/ifup eth0 the upload might resume, but stops again
shortly. The phenomenon seems to occur sooner if the path
to the remote system is _fast_ (low ping times).

The system in question works OK using the WLAN interface,
and also the wired connection works flawlessly in both
directions when running under (ugh!) WinXP.

# lspci
[...]
02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8036 PCI-E 
Fast Ethernet Controller (rev 10)

# cat /proc/interrupts
[...]
  17:      10568   IO-APIC-level  yenta, uhci_hcd:usb5, sky2, 
i915@pci:0000:00:02.0

Any ideas...?

Please CC replies to wikne@cheetah.uio.no


Regards,
-- Jon Wikne
Department of Physics
University of Oslo
Norway

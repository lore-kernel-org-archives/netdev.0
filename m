From: Anthony DeRobertis <asd@suespammers.org>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Tue, 11 Jul 2006 22:46:14 -0400
Message-ID: <44B46276.5030006@suespammers.org>
References: <20060703205238.GA10851@deprecation.cyrius.com> <20060707141843.73fc6188@dxpl.pdx.osdl.net> <200607072328.51282.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, 341801@bugs.debian.org,
	kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Maxwell.derobert.net ([207.188.193.82]:22745 "EHLO
	Maxwell.derobert.net") by vger.kernel.org with ESMTP
	id S932354AbWGLCqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 22:46:51 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607072328.51282.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, here are the results with iommu=force. All of these are copied down
by hand, so please forgive any transcription errors:

2.6.12[1]: Last line displayed on screen is "ata1: dev 0 ATA max
UDMA/133 390721968 sectors, lba48". Then it sits there. Scrolling with
shift-pgup/pgdown works. Control-Alt-Del reboots the machine. According
to /var/log/dmesg, the next line --- which never appears --- should be
"ata1: dev 0 configured for UDMA/133"

2.6.17-1: The kernel panics with a null pointer dereference on loading
uhci_hcd. The addresses given are usb_kick_khud+7, usb_hc_died+106,
pcibios_set_master+30, etc. After the panic, it sits there (just like
2.6.12)

2.6.17-mm6: The last line displayed is "SATA link up 1.5 Gbps SStatus
113 Scontrol 300". It completely hangs: neither scrolling nor
control-alt-del work.


Honestly, should I chuck this board through the window of my nearest
ASUS and/or VIA office, and buy an NForce board?

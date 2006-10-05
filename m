From: Steve Fox <drfickle@us.ibm.com>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Thu, 05 Oct 2006 15:42:33 -0500
Message-ID: <1160080954.29690.44.camel@flooterbu>
References: <20060928014623.ccc9b885.akpm@osdl.org>
	 <200610052027.02208.ak@suse.de> <1160074263.29690.23.camel@flooterbu>
	 <200610052105.00359.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Badari Pulavarty <pbadari@us.ibm.com>,
	Martin Bligh <mbligh@mbligh.org>, vgoyal@in.ibm.com,
	Andrew Morton <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kmannth@us.ibm.com, Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:29312 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S932083AbWJEUmi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 16:42:38 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200610052105.00359.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-05 at 21:05 +0200, Andi Kleen wrote:

> Can you please try it again with this patch to narrow it down further?

Unfortunately this is as far as it got before it hung.

root (hd0,0)
 Filesystem type is reiserfs, partition type 0x83
kernel /boot/vmlinuz-autobench root=/dev/sda1 vga=791  ip=9.47.67.239:9.47.67.5
0:9.47.67.1:255.255.255.0 resume=/dev/sdb1 showopts console=tty0 console=ttyS0,
57600 autobench_args: root=/dev/sda1 ABAT:1160080320
   [Linux-bzImage, setup=0x1400, size=0x1dd871]
initrd /boot/initrd-autobench.img
   [Linux-initrd @ 0x37ceb000, 0x304c57 bytes]


-- 

Steve Fox
IBM Linux Technology Center

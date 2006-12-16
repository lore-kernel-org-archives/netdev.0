From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [S2IO] De-typedef driver
Date: Sat, 16 Dec 2006 11:39:46 -0500
Message-ID: <45842152.10408@garzik.org>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77010097D1@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34820 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161122AbWLPQjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 11:39:53 -0500
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77010097D1@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
>> I stomped over the s2io driver when doing an allyesconfig build for
> IP27
>> where there was a namespace collision between the IP27 code and the
> s2io
>> driver which both use a nic_t.  I decieded both were broken, IP27
> should
>> not export the type and s2io was a totally typedef polluted piece of
> code.
>> So here's the s2io part of the fix.
> [Ram] Agreed this is a problem. Please leave the typedef but change
> nic_t to xframe_t. This will make it unique and is a much simpler
> change.

More simple yes, but not any closer to the Linux kernel (and POSIX) 
preferred style.

Most kernel devs' brains work better after applying Ralf's patch...

	Jeff




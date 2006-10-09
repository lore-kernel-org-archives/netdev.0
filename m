From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Exact meaning of rx_bytes and tx_bytes
Date: Mon, 9 Oct 2006 09:22:53 -0700
Message-ID: <20061009092253.6cfbd406@freekitty>
References: <200610091739.02361.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25561 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964774AbWJIRYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 13:24:36 -0400
To: Jean Delvare <jdelvare@suse.de>
In-Reply-To: <200610091739.02361.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Oct 2006 17:39:02 +0200
Jean Delvare <jdelvare@suse.de> wrote:

> Hi all,
> 
> I am wondering what exactly the rx_bytes and tx_bytes values exported 
> under statistics/ in sysfs are supposed to represent.
> 
> Most popular ethernet drivers (8139too, e100, 3c59x) count the bytes in 
> software, so they only take into account the bytes they actually send and 
> receive. This excludes the 4-byte ethernet CRC if I understand correctly.
> 
> Other drivers, on the other hand, get the transfered bytes statistics from 
> hardware registers, and these appear to include the 4-byte CRC in the 
> total count. This is the case of sk98lin and e1000, for example.
> 
> So my question is, which drivers are right? Are we counting the emitted 
> and received bytes at software level or at hardware level? Or do we just 
> not care about the 4-byte/packet difference and both are acceptable?
> 
> Thanks,

Does it really mater that much, unless you are charging people per
byte.


-- 
Stephen Hemminger <shemminger@osdl.org>

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Oops in e100_up
Date: Wed, 22 Aug 2007 09:35:04 -0700
Message-ID: <46CC65B8.1030006@intel.com>
References: <200708220956.48297@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34883 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762797AbXHVQfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 12:35:05 -0400
In-Reply-To: <200708220956.48297@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit Renker wrote:
> With the davem-2.6.24 tree I get the following Oops in the e100 driver (cribbed from console):
> 
> Code: 6c ff ff ff 8b 48 0c ba 01 00 00 00 89 f0 e8 1b f2 ff ff c7 86 9c 00 00 00
>       01 00 00 00 e9 4e ff ff ff 89 d0 e8 b3 f8 0b 00 eb 8e <0f> 0b eb fe 55 89 e5
>       56 53 83 ec 0c 8b 98 dc 01 00 00 e8 ff b9
> 
> EIP: e100_up+0x11d/0x121 
> 
> SS:ESP 0068:f759ce38
> 
> Stack: syscall_call -> sys_ioctl -> vfs_ioctl -> do_ioctl -> sock_ioctl -> inet_ioctl -> devinet_ioctl ->
>        dev_change_flags -> dev_open -> e100_open -> oops
> 
> The system log then goes on reporting "eth0: link up, 100Mbps, full-duplex" and hangs while trying to
> restore the serial console state (not sure that this is related).

restore? Is this during resume from suspend or something?

Auke

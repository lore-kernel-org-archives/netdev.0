From: =?UTF-8?B?IlRob21hcyBCLiBSw7xja2VyIg==?= <dm8tbr@openpma.org>
Subject: Re: UDP checksum broken since 2.6.18?
Date: Tue, 22 May 2007 23:33:30 +0000
Message-ID: <46537DCA.7060603@openpma.org>
References: <465364EA.3020100@openpma.org> <20070522161217.20875c39@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	=?UTF-8?B?UGhpbGk=?= =?UTF-8?B?cHAgR8O8aHJpbmc=?=
	<pg@futureware.at>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn-da.werderstrasse.de ([217.195.43.101]:57007 "EHLO
	dk0td.afthd.tu-darmstadt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756104AbXEVXdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:33:32 -0400
In-Reply-To: <20070522161217.20875c39@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The packet passed to packet capture programs may not have a valid checksum
> if you have checksum offload configured on the device.  What kind of hardware
> do you have on sender and receiver? 
The c-snippet uses 127.x.x.x --> loopback
I think Philipp tested this on real NICs too.

I just proxied this information to this list because I don't have the
indepth knowledge about IP, UDP and the kernel. I had a Chat with Ralf
Baechle and he recommended sending a report to netdev@. Maybe Philipp
can give some more information. He discovered this.

Cheers

Thomas

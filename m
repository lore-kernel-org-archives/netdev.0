From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [net 2/2] ixgbe: fix WoL issue with fiber
Date: Sat, 14 Apr 2012 20:47:53 +0200
Message-ID: <4F89C659.4080702@computer.org>
References: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com> <1334393478-31885-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:23555 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755102Ab2DNStt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 14:49:49 -0400
In-Reply-To: <1334393478-31885-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Don Skidmore<donald.c.skidmore@intel.com>
>
> There are times we turn of the laser before shutdown.  This is a bad thing
> if we want to wake on lan to work so now we make sure the laser is on
> before shutdown if we support WoL.

I'm ever-so-sorry if this is a silly question, but:

WOL is receive-only, right? Why does the laser need to be on?

Thanks, Jan

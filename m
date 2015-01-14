From: thomas Graf <tgraf@suug.ch>
Subject: Re: non-OVS based vxlan config broken on 3.19-rc ?!
Date: Wed, 14 Jan 2015 15:52:08 +0000
Message-ID: <20150114155208.GA24550@casper.infradead.org>
References: <54B688D9.8030101@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom Herbert <therbert@google.com>,
	Marcelo Leitner <mleitner@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59806 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbbANPwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:52:09 -0500
Content-Disposition: inline
In-Reply-To: <54B688D9.8030101@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 05:18pm, Or Gerlitz wrote:
> Guys, just realized that non-OVS based vxlan config is broken with
> 3.19-rc... I see that it works for me on 3.18.2 and breaks on 3.19-rc3
> (Linus tree). Tested over mlx4 (both offloaded and non offloaded modes) and
> igb, see below the simplest form I can see it breaks on 3.19-rcand works on
> 3.18
> 
> Looking on tcpdump and stats, the arp reply arrives to the 3.19-rc host NIC
> driver but is dropped along the stack beforehanded to the vxlan driver, not
> sure where and why...

As additional data point: I tested the VXLAN-GBP with iproute2 based tunnels
on net-next and that works fine. Driver used was a e1000 in KVM.

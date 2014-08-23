From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 12/12] rocker: introduce rocker switch driver
Date: Sat, 23 Aug 2014 15:04:50 +0100
Message-ID: <20140823140450.GA24116@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-13-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33605 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaHWOFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 10:05:00 -0400
Content-Disposition: inline
In-Reply-To: <1408637945-10390-13-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/14 at 06:19pm, Jiri Pirko wrote:
> This patch introduces the first driver to benefit from the switchdev
> infrastructure and to implement newly introduced switch ndos. This is a
> driver for emulated switch chip implemented in qemu:
> https://github.com/sfeldma/qemu-rocker/

The design looks very clean. I noticed that the TLV API is almost an
exact dupliate of the Netlink attributes API. Any specific reason for
not reusing lib/nlattr.c and add what is missing?

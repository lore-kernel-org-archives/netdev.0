From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Tue, 19 May 2009 15:19:02 +0300
Message-ID: <4A12A3B6.9020505@Voltaire.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com>	<200905142128.58111.rusty@rustcorp.com.au> <4A0C2500.7090709@Voltaire.com> <200905151448.49851.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29620 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751234AbZESMTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 08:19:09 -0400
In-Reply-To: <200905151448.49851.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> This patch may help diagnostics tho.
> virtio: expose features in sysfs
> 
> Each device negotiates feature bits; expose these in sysfs to help
> diagnostics and debugging.

okay, this is the info from my guest after applying the patch on its kernel.

Or.


[root@vm1 ~]# lspci | grep Ethernet
00:03.0 Ethernet controller: Qumranet, Inc. Virtio network device

[root@vm1 ~]# cat /sys/class/net/eth0/features
0x20

[root@vm1 ~]# cat /sys/class/net/eth0/device/features
0000010000000000000000001000000000000000000000000000000000000000




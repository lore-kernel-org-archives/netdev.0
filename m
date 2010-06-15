From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Tue, 15 Jun 2010 14:20:30 +0900
Message-ID: <4C170D9E.5090407@jp.fujitsu.com>
References: <4C11915E.6090201@jp.fujitsu.com> <201006151358.12071.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:37616 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab0FOFWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 01:22:00 -0400
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5F5LwtY017895
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Tue, 15 Jun 2010 14:21:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0296F45DE51
	for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 14:21:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7EA145DE4D
	for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 14:21:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ABF631DB8045
	for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 14:21:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F377E18005
	for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 14:21:57 +0900 (JST)
In-Reply-To: <201006151358.12071.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

(2010/06/15 13:28), Rusty Russell wrote:
> On Fri, 11 Jun 2010 10:59:02 am Taku Izumi wrote:
>> This patch implements ethtool_ops.get_drvinfo interface of virtio_net driver.
>>
>> Signed-off-by: Taku Izumi<izumi.taku@jp.fujitsu.com>
> 
> Hi Taku!
> 
>     Does this have any useful effect?

I often use "ethtool -i" command to check what driver controls the ehternet device.
But because current virtio_net driver doesn't support "ethtool -i", it becomes the
following:

	# ethtool -i eth3
	Cannot get driver information: Operation not supported

My patch simply adds the "ethtool -i" support. The following is the result when
using the virtio_net driver with my patch applied to.

	# ethtool -i eth3
	driver: virtio_net
	version: N/A
	firmware-version: N/A
	bus-info: virtio0

Personally, "-i" is one of the most frequently-used option, and
most network drivers support "ethtool -i", so I think virtio_net also should do.

Taku Izumi <izumi.taku@jp.fujitsu.com>






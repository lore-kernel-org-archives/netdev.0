From: Jason Wang <jasowang@redhat.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Sun, 22 Sep 2013 14:29:15 +0800
Message-ID: <523E8E3B.3050805@redhat.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Anirban Chakraborty <abchak@juniper.net>,
	Ian Campbell <ian.campbell@citrix.com>, xen-devel@lists.xen.org
To: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466Ab3IVG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 02:29:27 -0400
In-Reply-To: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2013 12:05 AM, Wei Liu wrote:
> Anirban was seeing netfront received MTU size packets, which downgraded
> throughput. The following patch makes netfront use GRO API which
> improves throughput for that case.
>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Signed-off-by: Anirban Chakraborty <abchak@juniper.net>
> Cc: Ian Campbell <ian.campbell@citrix.com>

Maybe a dumb question: doesn't Xen depends on the driver of host card to
do GRO and pass it to netfront? What the case that netfront can receive
a MTU size packet, for a card that does not support GRO in host? Doing
GRO twice may introduce extra overheads.

Thanks

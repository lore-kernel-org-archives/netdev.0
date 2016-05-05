From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] vxlan: if_arp: introduce ARPHRD_VXLANGPE
Date: Thu, 5 May 2016 21:31:41 +0200
Message-ID: <20160505213141.7ad29ebd@griffin>
References: <1462466204-3534-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755702AbcEETbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 15:31:45 -0400
In-Reply-To: <1462466204-3534-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 May 2016 13:36:44 -0300, Thadeu Lima de Souza Cascardo wrote:
> Use ARPHRD_VXLANGPE to identify VxLAN GPE interfaces. This is going to be used
> to allow GPE interfaces to be added as openvswitch ports.

What's wrong with ARPHRD_NONE? I don't think we need a separate type
for VXLAN-GPE. Just use ARPHRD_NONE in ovs and things should work, for
all ARPHRD_NONE interfaces as a bonus.

> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Cc: Jiri Benc <jbenc@redhat.com>
> Cc: Simon Horman <simon.horman@netronome.com>

You did not CC me nor Simon :-)

 Jiri

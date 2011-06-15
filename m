From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] tun: teach the tun/tap driver to support netpoll
Date: Wed, 15 Jun 2011 13:50:38 -0400
Message-ID: <4DF8F0EE.4070009@redhat.com>
References: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Maxim Krasnyansky <maxk@qualcomm.com>,
	Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618Ab1FORuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 13:50:52 -0400
In-Reply-To: <1308151501-8434-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2011 11:25 AM, Neil Horman wrote:
> Commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093 changed the behavior of slave
> devices in regards to netpoll.  Specifically it created a mutually exclusive
> relationship between being a slave and a netpoll-capable device.  This creates
> problems for KVM because guests relied on needing netconsole active on a slave
> device to a bridge.  Ideally libvirtd could just attach netconsole to the bridge
> device instead, but thats currently infeasible, because while the bridge device
> supports netpoll, it requires that all slave interface also support it, but the
> tun/tap driver currently does not.  The most direct solution is to teach tun/tap
> to support netpoll, which is implemented by the patch below.
>
> I've not tested this yet, but its pretty straightforward.

I have tested it.  I can run netconsole and my KVM guests
simultaneously again.

Thank you, Neil!

Now all I have to do is log whatever other bugs are haunting
3.0-rc and causing my system to hang :)

> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> Reported-by: Rik van Riel<riel@redhat.com>
> CC: Rik van Riel<riel@redhat.com>
> CC: Maxim Krasnyansky<maxk@qualcomm.com>
> CC: Cong Wang<amwang@redhat.com>
> CC: "David S. Miller"<davem@davemloft.net>

Reviewed-by: Rik van Riel <riel@redhat.com>
Tested-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] net: allow notifier subscribers to forbid
 device from closing
Date: Wed, 31 Aug 2011 08:20:08 -0700
Message-ID: <20110831082008.1c2f0c14@nehalam.ftrdhcpuser.net>
References: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57984 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756094Ab1HaPT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:19:57 -0400
In-Reply-To: <1314803731-1222-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 17:15:31 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> In some situations, like when the device is used as slave device in
> bond/br/etc it is not nice if someone closes the device. This allows
> it's masters to forbid this closure.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I don't think this is necessary, for bridging case.
bridging handles it. And bonding should as well.
It is a good way to test STP etc.

Is this a case of "you really shouldn't do this", or
"don't do this it will crash"? In general Linux allows the
former and uses references to prevent the later.

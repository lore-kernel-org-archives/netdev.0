From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: packet_getname_spkt: make sure string is
 always 0-terminated
Date: Thu, 13 Jun 2013 01:38:59 -0700 (PDT)
Message-ID: <20130613.013859.1357765580190105873.davem@davemloft.net>
References: <1371045747-15203-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab3FMIjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:39:00 -0400
In-Reply-To: <1371045747-15203-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 12 Jun 2013 16:02:27 +0200

> uaddr->sa_data is exactly of size 14, which is hard-coded here and
> passed as a size argument to strncpy(). A device name can be of size
> IFNAMSIZ (== 16), meaning we might leave the destination string
> unterminated. Thus, use strlcpy() and also sizeof() while we're
> at it. We need to memset the data area beforehand, since strlcpy
> does not padd the remaining buffer with zeroes for user space, so
> that we do not possibly leak anything.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, and queued up for -stable, thanks.

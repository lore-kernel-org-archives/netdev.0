From: Laurent CARON <lcaron@lncsa.com>
Subject: Re: Regarding bug 82471
Date: Mon, 29 Sep 2014 10:48:10 +0200
Message-ID: <54291CCA.8070809@lncsa.com>
References: <542595D6.6040904@lncsa.com> <20140929055156.GA13693@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-siege-002.lncsa.com ([46.21.113.22]:51208 "EHLO
	smtp-out-siege-002.lncsa.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751621AbaI2IsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 04:48:09 -0400
In-Reply-To: <20140929055156.GA13693@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/09/2014 07:51, Michal Kubecek wrote:
> I don't see why it would affect ixgbe adapters which support Tx VLAN
> offloading (and with which the original patch was tested) but the
> symptoms look very much like those fixed by commit db115037bb57 ("net:
> fix checksum features handling in netif_skb_features()"). Could you
> please test with 3.17-rc5 or later?

Hi Michal,

Just compiled 3.17-rc7 and it seems it is fixed. Will report later on on 
this, but since the issue appears very shortly after server startup, we 
should be all set.

Thanks

Laurent

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: veth: Set features for MPLS
Date: Wed, 17 Aug 2016 15:41:20 -0700
Message-ID: <1471473680.29842.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
	 <1471470587-24813-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	buytenh@wantstofly.org, simon.horman@netronome.com,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com,
	alexander.duyck@gmail.com, Simon Horman <horms@verge.net.au>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35645 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcHQWlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 18:41:22 -0400
Received: by mail-pa0-f65.google.com with SMTP id cf3so165118pad.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 15:41:21 -0700 (PDT)
In-Reply-To: <1471470587-24813-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 14:49 -0700, David Ahern wrote:
> veth does not really transmit packets only moves the skb from one
> netdev to another so gso and checksum is not really needed. Add
> the features to mpls_features to get the same benefit and performance
> with MPLS as without it.

It seems mpls_features should also be managed by bonding and team
drivers ...

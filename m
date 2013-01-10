From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 02/14] bridge: Add vlan filtering
 infrastructure
Date: Thu, 10 Jan 2013 14:10:05 -0800
Message-ID: <20130110141005.427ccaf9@nehalam.linuxnetplumber.net>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
	<1357751882-8619-3-git-send-email-vyasevic@redhat.com>
	<20130110103614.23383079@nehalam.linuxnetplumber.net>
	<50EF0FF7.3080407@redhat.com>
	<50EF1537.7030209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52171 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab3AJWLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 17:11:32 -0500
In-Reply-To: <50EF1537.7030209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem with your approach is that it 
adds a hash lookup in the packet process critical path.

Also the concept of different filters for egress vs ingress is feature
madness. It doesn't make sense to have half-duplex connectivity.

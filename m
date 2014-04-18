From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] sctp: add support for busy polling to sctp protocol
Date: Fri, 18 Apr 2014 11:39:54 +0200
Message-ID: <5350F2EA.8030003@redhat.com>
References: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbaDRKZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 06:25:03 -0400
In-Reply-To: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2014 09:26 PM, Neil Horman wrote:
> The busy polling socket option adds support for sockets to busy wait on data
> arriving on the napi queue from which they have most recently received a frame.
> Currently only tcp and udp support this feature, but theres no reason sctp can't
> do so as well.  Add it in so appliations can take advantage of it
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Daniel Borkmann <dborkman@redhat.com>
> CC: netdev@vger.kernel.org

Acked-by: Daniel Borkmann <dborkman@redhat.com>

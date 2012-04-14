From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] tcp:Remove redundant code entering quickack
 mode
Date: Sat, 14 Apr 2012 02:01:03 -0300
Message-ID: <20120414020103.302f2c66@asterix.rh>
References: <1334359439-10147-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080Ab2DNFBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 01:01:09 -0400
In-Reply-To: <1334359439-10147-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Apr 2012 16:23:59 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> tcp_enter_quickack_mode() already calls tcp_incr_quickack() and sets
> icsk->icsk_ack.ato  to TCP_ATO_MIN. This patch removes the duplication.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Reviewed-by: Flavio Leitner <fbl@redhat.com>

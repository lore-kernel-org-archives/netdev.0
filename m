From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 09:42:03 -0300
Message-ID: <20150928124203.GB24740@localhost.localdomain>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933011AbbI1MmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 08:42:07 -0400
Content-Disposition: inline
In-Reply-To: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 02:34:04PM +0200, Denys Vlasenko wrote:
> Seemingly innocuous sctp_trans_state_to_prio_map[] array
> is way bigger than it looks, since
> "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
> 
> This patch replaces it with switch() statement.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> CC: linux-sctp@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

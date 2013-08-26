From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: reorder sctp_globals to reduce
 cacheline usage
Date: Mon, 26 Aug 2013 11:29:41 -0400
Message-ID: <20130826152941.GA30662@hmsreliant.think-freely.org>
References: <1377527640-22447-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59324 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3HZP3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 11:29:54 -0400
Content-Disposition: inline
In-Reply-To: <1377527640-22447-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 04:34:00PM +0200, Daniel Borkmann wrote:
> Reduce cacheline usage from 2 to 1 cacheline for sctp_globals structure. By
> reordering elements, we can close gaps and simply achieve the following:
> 
> Current situation:
>   /* size: 80, cachelines: 2, members: 10 */
>   /* sum members: 57, holes: 4, sum holes: 16 */
>   /* padding: 7 */
>   /* last cacheline: 16 bytes */
> 
> Afterwards:
>   /* size: 64, cachelines: 1, members: 10 */
>   /* padding: 7 */
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: reuse sent_count to avoid retransmitted
 chunks for RTT measurements
Date: Mon, 10 Oct 2016 16:56:32 -0300
Message-ID: <20161010195632.GA23201@localhost.localdomain>
References: <b68194a4735a1ea5a652c13540df5d68e3c4b305.1475897765.git.lucien.xin@gmail.com>
 <20161010174825.GC2958@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
        davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751307AbcJJT5W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 15:57:22 -0400
Content-Disposition: inline
In-Reply-To: <20161010174825.GC2958@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 02:48:25PM -0300, Marcelo Ricardo Leitner wrote:
> On Sat, Oct 08, 2016 at 11:36:05AM +0800, Xin Long wrote:
> > Now sctp uses chunk->resent to record if a chunk is retransmitted, for
> > RTT measurements with retransmitted DATA chunks. chunk->sent_count was
> > introduced to record how many times one chunk has been sent for prsctp
> > RTX policy before. We actually can know if one chunk is retransmitted
> > by checking chunk->sent_count is greater than 1.
> > 
> > This patch is to remove resent from sctp_chunk and reuse sent_count
> > to avoid retransmitted chunks for RTT measurements.
> > 
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> 
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Though you may have to resend later, as we are still in merge window and
we shouldn't be posting net-next patches during it.

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next 1/2] af_packet: TX_RING support for TPACKET_V3
Date: Mon, 2 Jan 2017 18:07:24 -0500
Message-ID: <20170102230724.GE31716@oracle.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com>
 <bc66616d08758cfe225a4b02316b72de16e00302.1483309545.git.sowmini.varadhan@oracle.com>
 <CAF=yD-J2Sw0=iTuvPe-sa01Ld0D1U6f=R-99WLRKggap_WKdug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18058 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933055AbdABXHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 18:07:41 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-J2Sw0=iTuvPe-sa01Ld0D1U6f=R-99WLRKggap_WKdug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/02/17 17:57), Willem de Bruijn wrote:
> One more point. We should validate the tpacket_req3 input and fail if
> unsupported options are passed. Specifically, fail if any of
> {tp_retire_blk_tov, tp_sizeof_priv, tp_feature_req_word} is non-zero.
> 
> Otherwise looks good to me.

Ok, I'll send out v3 tomorrow, with the test case also updated
to share code with walk_v1_v2_tx as cleanly as possible. 

Thanks for the review feedback!

--Sowmini

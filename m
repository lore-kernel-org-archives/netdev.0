From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [net-next v2 02/13] tcp: tcp_v[46]_conn_request: fix snt_synack initialization
Date: Fri, 27 Jun 2014 22:24:25 -0400
Message-ID: <CADVnQyki0a4J9u2+WD7o01b6+3SSjWHSkeU9NGf0h0SWedt2Uw@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
	<CADVnQykKYPVt-g8WtE29Xu_0Si-Lx_pMxnix4i2BqFhAV9BD8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Daniel Lee <longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36093 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbaF1CY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 22:24:27 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so5910125wgg.8
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 19:24:25 -0700 (PDT)
In-Reply-To: <CADVnQykKYPVt-g8WtE29Xu_0Si-Lx_pMxnix4i2BqFhAV9BD8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 10:16 PM, Neal Cardwell <ncardwell@google.com> wrote:
> So I would suggest that we fix this inconsistency you have noted by
> removing the two lines in tcp_v4_send_synack() that touch snt_synack.
> That is the approach we have been using at Google recently, and I
> think it was an oversight that we didn't remove those two lines.

I see David merged the patch series tonight, so since I came late to
the party I'm happy to make and test this change if there is consensus
that this is reasonable.

neal

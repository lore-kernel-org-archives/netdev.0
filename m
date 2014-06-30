From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [net-next v2 02/13] tcp: tcp_v[46]_conn_request: fix snt_synack initialization
Date: Mon, 30 Jun 2014 15:11:33 -0400
Message-ID: <CADVnQy=Fu-fJDczTLjQPreGq2-++S9sp2akj84Orv5p_b3Qc=g@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
	<CADVnQykKYPVt-g8WtE29Xu_0Si-Lx_pMxnix4i2BqFhAV9BD8Q@mail.gmail.com>
	<CAE1zotKXSqy0O+OQq1f+ab7k3hL4ntMwk3CX4pOYUXoVeGjb7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Daniel Lee <longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:54103 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756759AbaF3TLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 15:11:34 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so8624426wev.6
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 12:11:33 -0700 (PDT)
In-Reply-To: <CAE1zotKXSqy0O+OQq1f+ab7k3hL4ntMwk3CX4pOYUXoVeGjb7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 7:50 AM, Octavian Purdila
<octavian.purdila@intel.com> wrote:
> In that case perhaps it is better to add a new field (or rename the
> existing one if it is not needed anymore) to store the syn arrival
> time? I think it is confusing to store the syn arrival time in the
> "synack sent time" field.

That would be reasonable, but I think the longstanding "snt_synack"
name is also good, since the primary purpose of that field is to
measure the RTT of the SYNACK packet.

neal

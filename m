From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: Query regarding sk_filter
Date: Tue, 13 Jan 2015 00:00:59 +0600
Message-ID: <20150112180057.GA16489@kumar-pc.asicdesigners.com>
References: <CAADnVQJx+6Pv0qTSkKgnW8aqCwVtz4oDaVC6tR-Df6XFFrjMDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10497 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412AbbALSbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 13:31:18 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQJx+6Pv0qTSkKgnW8aqCwVtz4oDaVC6tR-Df6XFFrjMDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, January 01/12/15, 2015 at 10:17:16 -0800, Alexei Starovoitov wrote:
> On Sat, Jan 10, 2015 at 4:40 AM, Kumar Sanghvi <kumaras@chelsio.com> wrote:
> >
> > May be, the question that I should have asked is : do child socket and parent listening socket have the
> > same sk_filter applied i.e. do child socket inherit sk_filter from parent listening socket ?
> 
> yes. socket returned from accept() inherits filter from parent socket.
> if you're curious the path is:
> tcp_check_req - tcp_v4_syn_recv_sock - tcp_create_openreq_child - sk_clone_lock
>
Got it. Thanks! 

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 21 Sep 2015 18:53:33 -0400
Message-ID: <20150921225333.GE3861@oracle.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
 <20150921122422.GA31092@oracle.com>
 <CALx6S34gmbEybQKmsL2=0wGh+LjktBLSimpOCrxWUyTYFFUhfA@mail.gmail.com>
 <20150921212624.GD3861@oracle.com>
 <CALx6S349QY_U8KVtnwDc_yFMXdZ9h1WvnpjWU9FYPTNuQ0yt7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47369 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbbIUWxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:53:42 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S349QY_U8KVtnwDc_yFMXdZ9h1WvnpjWU9FYPTNuQ0yt7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/21/15 15:36), Tom Herbert wrote:
> segments. What we need to do, which you're probably doing for RDS, is
> do message delineation on the stream as a sequence of:
> 
> 1) Read protocol header to determine message length (BPF used here)

right, that's what rds does- first reads the sizeof(rds_header),
and from that, figures out payload len, to stitch each rds dgram 
together from intermediate tcp segments..

> 2) Read data up to the length of the message
> 3) Deliver message
> 4) Goto #1 (i.e. process next message in the stream).

Thanks for the rest of the responses.

--Sowmini

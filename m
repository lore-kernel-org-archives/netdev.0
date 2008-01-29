From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Tue, 29 Jan 2008 10:10:30 +0100
Message-ID: <20080129091030.GB1624@ff.dom.local>
References: <20080127232018.GA2856@ami.dom.local> <Pine.LNX.4.58.0801290139450.3181@u.domain.uli> <20080129084915.GA1624@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:51756 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbYA2JDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 04:03:41 -0500
Received: by fk-out-0910.google.com with SMTP id z23so1336493fkz.5
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 01:03:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080129084915.GA1624@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2008 at 09:49:15AM +0100, Jarek Poplawski wrote:
> On Tue, Jan 29, 2008 at 02:30:47AM +0200, Julian Anastasov wrote:
...
> > 	fa_match is some existing alias that matches all new parameters.
> > As NLM_F_REPLACE changes the first alternative route for 
> > tos+priority if fa_match == fa_first (we are replacing alias that
> > matches all parameters) we return 0, only that routing cache is not 
> > flushed - nothing is replaced/changed. So, "fa == fa_match" means
> > "replace will not change existing parameters", return 0 as this is
> > not an error.
> 
> Probably I miss something, but what parameters do we change if
> (fa_match) && (fa != fa_match)? Isn't this "goto out" in any case?

OOPS! You mean change is needed, but we can't do this! (I'm so slow...)

All correct!

Thanks again,
Jarek P.

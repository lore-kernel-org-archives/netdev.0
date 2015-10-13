From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] route: fib_validate_source remove the <=
 RT_SCOPE_HOST test
Date: Tue, 13 Oct 2015 22:24:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1510132223030.2336@ja.home.ssi.bg>
References: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
	fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46578 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751851AbbJMTZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 15:25:04 -0400
In-Reply-To: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 14 Oct 2015, Xin Long wrote:

> commit fe3edf45792a ("ipv4: Remove all RTCF_DIRECTSRC handliing.").
> 
> Before this commit, we had a tristate:
> < 0: error
> 0: ok
> 1: ok and set RTCF_DIRECTSRC
> 
> But now we only care about 0 or < 0.

	Not true, __mkroute_input() uses the 'err' result
to set IPSKB_DOREDIRECT.

Regards

--
Julian Anastasov <ja@ssi.bg>

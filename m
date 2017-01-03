From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH v2] scm: fix possible control message header alignment
 issue
Date: Tue, 3 Jan 2017 00:52:37 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A4CA6B@cnshjmbx04>
References: <1483015172-5017-1-git-send-email-cugyly@163.com>
 <20161230.152057.1192922867281184266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:46258 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756034AbdACBH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 20:07:56 -0500
In-Reply-To: <20161230.152057.1192922867281184266.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, December 31, 2016 4:21 AM
> To: cugyly@163.com
> Cc: netdev@vger.kernel.org; YUAN Linyu
> Subject: Re: [PATCH v2] scm: fix possible control message header alignment
> issue
> If you can come up with a case where this does happen in
> practice, I will continue to consider this patch.
> 
Yes, before send patch I also check two archs(arm-v7 and powerpc e6500), they are aligned.
No one report issue, I think cmsghdr aligned on all archs.

> Otherwise, we should make the assumptions that exist explicit
> and get rid of all of the code that does that funny alignment
> upon the cmsghdr structure.
> 
Do you accept that I remove all CMSG{_COMPAT}_ALIGN of header ?

> Thanks.

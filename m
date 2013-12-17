From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2] xen-netback: fix some error return code
Date: Tue, 17 Dec 2013 09:49:36 +0000
Message-ID: <20131217094936.GA26994@zion.uk.xensource.com>
References: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
 <20131216131313.GE12582@zion.uk.xensource.com>
 <1387201238.10247.37.camel@kazak.uk.xensource.com>
 <CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
 <1387203160.21086.1.camel@kazak.uk.xensource.com>
 <CAPgLHd9Q7A--LQnsMKt-Tt-FwrA3FC1Un3kwLRH5pc4Z3N2K7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <Ian.Campbell@citrix.com>, <wei.liu2@citrix.com>,
	<yongjun_wei@trendmicro.com.cn>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25543 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950Ab3LQJth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 04:49:37 -0500
Content-Disposition: inline
In-Reply-To: <CAPgLHd9Q7A--LQnsMKt-Tt-FwrA3FC1Un3kwLRH5pc4Z3N2K7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 10:42:09AM +0800, Wei Yongjun wrote:
> 'err' is overwrited to 0 after maybe_pull_tail() call, so the error
> code was not set if skb_partial_csum_set() call failed. Fix to return
> error -EPROTO from those error handling case instead of 0.
> 
> Fixes: d52eb0d46f36 ('xen-netback: make sure skb linear area covers checksum field')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Wei Liu <wei.liu2@citrix.com>

This makes sense. This patch applies to 'net' tree. You should specify
'net' or 'net-next' tree in subject line for your future patch. You can
find relevant infomation in netdev-FAQ.txt in kernel documentation
directory.

Thanks
Wei.

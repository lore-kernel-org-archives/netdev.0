From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 23:46:49 -0700
Message-ID: <20120418234649.0bcb3872@nehalam.linuxnetplumber.net>
References: <4F8F77F5.8020201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	ctrix+debianbugs@navynet.it, Eric Dumazet <eric.dumazet@gmail.com>,
	harry.majun@huawei.com, linux-kernel@vger.kernel.org,
	peter.huangpeng@gmail.com
To: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900Ab2DSGq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 02:46:57 -0400
In-Reply-To: <4F8F77F5.8020201@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Apr 2012 10:27:01 +0800
"Peter Huang(Peng)" <peter.huangpeng@huawei.com> wrote:

> When bridge is deleted before tap/vif device's delete, kernel may 
> encounter an oops because of NULL reference to fake_rtable's dst.
> Set fake_rtable's dst to NULL before sending packets out can solve this 
> problem.
> 
> v3 enrich commit header
> 
> v2 added a new flag DST_FAKE_RTABLE to dst_entry struct.
> 
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>

I am okay with the contents of the patch but the formatting is all
botched. It adds bad indentation and whitespace, please run it
through checkpatch. 

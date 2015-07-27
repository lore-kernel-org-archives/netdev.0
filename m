From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 27 Jul 2015 16:19:48 -0700
Message-ID: <20150727231947.GC2832181@devbig242.prn2.facebook.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ncardwell@google.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	FB Kernel Team <kernel-team@fb.com>
To: Jovi Zhangwei <jovi@cloudflare.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:27262 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753578AbbG0XVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 19:21:16 -0400
Content-Disposition: inline
In-Reply-To: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 11:55:35AM -0700, Jovi Zhangwei wrote:
> Sorry for disturbing, our production system(3.14 and 3.18 stable
> kernel) have many tcp_fragment warnings,
> the trace is same as below one which you discussed before.
> 
> https://urldefense.proofpoint.com/v1/url?u=http://comments.gmane.org/gmane.linux.network/365658&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=fQUME5h%2FYY3oZjXbnLC3z6TaEEcTBSCAji4PkNqFjq8%3D%0A&s=1527f3221a6f31cba9544e5ddaa20986aafe8be8c898b42c7e9ce5e68d3803d8
> 
> But I didn't found the final solution in that mail thread, do you have
> any new ideas or patches on this warning?

I think the following points to the last discussion.  We are currently using a
similar patch:
http://comments.gmane.org/gmane.linux.network/366549

Eric, any update on your findings? or you have already pushed a fix?

Thanks,
--Martin

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC v3 net 0/2] ipv6: Avoid restarting fib6_lookup() for
 RTF_CACHE hit
Date: Tue, 07 Oct 2014 02:10:47 +0200
Message-ID: <1412640647.715513.175903877.4297257D@webmail.messagingengine.com>
References: <1412640315-22472-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41292 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252AbaJGAKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 20:10:48 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id D62AE2094F
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 20:10:47 -0400 (EDT)
In-Reply-To: <1412640315-22472-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014, at 02:05, Martin KaFai Lau wrote:
> Notes: Same as the last two versions but fixed a title and missing
> Signed-Off issue.
> 
> I am trying to understand why there is a need to restart fib6_lookup()
> after
> getting rt with RTF_CACHE.
> 
> I have adapted davem's udpflood test
> (https://urldefense.proofpoint.com/v1/url?u=https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=j4KoKiV%2FLl4Dx6wOKiDLZPDODlbMJ5UBybTiTzIRHTM%3D%0A&s=68cac2d1d239e23b104065419b4ad89ea80bc1401571034ccce3b4a52a98a8d3)
> to
> support IPv6 and here is the result:
> 
> #root > time ./udpflood -l 20000000 -c 250 2401:db00:face:face::2
> 
> Before:
> real    0m33.224s
> user    0m2.941s
> sys     0m30.232s
> 
> After:
> real    0m31.517s
> user    0m2.938s
> sys     0m28.536s

Thanks, Martin! I'll review them ASAP.

Bye,
Hannes

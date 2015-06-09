From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net v2] tcp: Force updating pcount after skb_pull()
 during mtu probing
Date: Tue, 9 Jun 2015 10:45:10 -0700
Message-ID: <20150609174510.GE390474@devbig242.prn2.facebook.com>
References: <1433551592-3596877-1-git-send-email-kafai@fb.com>
 <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150608175833.GB390474@devbig242.prn2.facebook.com>
 <1433787073.29864.54.camel@edumazet-glaptop2.roam.corp.google.com>
 <1433869585.29864.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12430 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752472AbbFIRp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:45:26 -0400
Content-Disposition: inline
In-Reply-To: <1433869585.29864.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 10:06:25AM -0700, Eric Dumazet wrote:
> I've been working on this, but still can get the bug triggering in
> tcp_fragment(), no matter what (Neal patch , yours, mine...)
Can you describe the test case that can reproduce it?

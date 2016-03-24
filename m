From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Thu, 24 Mar 2016 12:45:19 -0700
Message-ID: <20160324194519.GB95371@kafai-mba.local>
References: <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
 <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
 <20160322060220.GA50824@kafai-mba.local>
 <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
 <20160322173939.GA53936@kafai-mba.local>
 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
 <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
 <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
 <20160324183228.GA95371@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Wei Wang <weiwan@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <tracywwnj@gmail.com>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:18970 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbcCXTp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:45:28 -0400
Content-Disposition: inline
In-Reply-To: <20160324183228.GA95371@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 11:32:28AM -0700, Martin KaFai Lau wrote:
> Some fast path may do __sk_dst_get() which does not refcnt the sk->sk_dst_cache.
Ignore this comment.  This should have been protected by rcu grace period.

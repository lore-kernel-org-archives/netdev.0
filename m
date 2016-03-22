From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Tue, 22 Mar 2016 11:16:43 -0700
Message-ID: <20160322181643.GA56461@kafai-mba.local>
References: <CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
 <CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
 <CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
 <CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
 <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
 <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
 <20160322060220.GA50824@kafai-mba.local>
 <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
 <20160322173939.GA53936@kafai-mba.local>
 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Wei Wang <weiwan@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12675 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbcCVSRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 14:17:47 -0400
Content-Disposition: inline
In-Reply-To: <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 11:03:29AM -0700, Wei Wang wrote:
> But one thing here, we will have to generate the same flowi6 in both
> ip6_sk_update_pmtu() as well as ip6_update_pmtu(). Is this considered
> as a not clean enough fix?
If they share common codes to build flowi6, can the common codes
be factored out?

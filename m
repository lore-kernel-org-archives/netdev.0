From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal
 vports
Date: Wed, 13 Jan 2016 18:30:18 +0100
Message-ID: <1452706218.28238.2.camel@redhat.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
	 <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
	 <CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
	 <CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
	 <1452501788.5027.13.camel@redhat.com>
	 <CAOrHB_DL6DpyoLYZroccPR7mjUuMM-JN6p-=o6XE53Ltb_Cq0w@mail.gmail.com>
	 <CAEh+42hr8JneX5bufHNqbVFfnCXkU1iz7n0Pc4UQfm==rKF9Dw@mail.gmail.com>
	 <CAOrHB_C=GxDbZBdKCo0j2z-dNTKRQ6GcpWYr6qGxuF_SxughJg@mail.gmail.com>
	 <CAEh+42hvvNG7LRZtL0HjPFny7p2Cu_Bkv4k1aYQxXAWZST4yQQ@mail.gmail.com>
	 <CAOrHB_C0pt9=84t8Jzr1YL5n=Ap2frSy1rBipUqs84mGpg+o3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755578AbcAMRaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 12:30:23 -0500
In-Reply-To: <CAOrHB_C0pt9=84t8Jzr1YL5n=Ap2frSy1rBipUqs84mGpg+o3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-12 at 21:27 -0800, pravin shelar wrote:
> On Tue, Jan 12, 2016 at 5:08 PM, Jesse Gross <jesse@kernel.org> wrote:
> > Any traffic coming from the hypervisor itself (as well as tunnels
> > although unless you are doing double encapsulation then this patch
> > doesn't matter in that case).
> >
> 
> ok, But majority of traffic comes from VM. So IMO only this patch
> would not make much difference.
> 
> > Since we're in the merge window now, maybe it makes sense to just go
> > for the full version in the next cycle in any case.
> 
> ok.

Thank you for the feedback.

I'll try to implement a more general solution and get some performance
numbers for the next cycle,

Paolo

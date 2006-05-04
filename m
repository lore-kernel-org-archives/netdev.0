From: "Ian McDonald" <imcdnzl@gmail.com>
Subject: Re: latest -stable breaks Squid
Date: Thu, 4 May 2006 13:59:04 +1200
Message-ID: <cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>
	 <4459574D.6000303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Dave Jones" <davej@redhat.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org, fedora-list@list.zikzak.de,
	fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:25581 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750856AbWEDB7F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 21:59:05 -0400
Received: by wr-out-0506.google.com with SMTP id i12so274676wra
        for <netdev@vger.kernel.org>; Wed, 03 May 2006 18:59:05 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <4459574D.6000303@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/06, Ben Greear <greearb@candelatech.com> wrote:
> Herbert Xu wrote:
> > Dave Jones <davej@redhat.com> wrote:
> >
> >>So I pushed out an update for Fedora Core 5 users yesterday
> >>that moved the kernel from 2.6.16.9 to 2.6.16.13.
> >>I've since heard "My network performance is awful", and worse
> >>yet, some apps seem broken as in the report below.
> >>
> >>Anyone have any ideas ?
> >
> >
> > Try reverting the e1000 truesize patch.  Although the fix is 100%
> > correct, it might have a negative impact on user-space apps with
> > particuarly small rcvbuf settings.  Prior to the fix, due to the
> > incorrect accounting we are essentially enlarging rcvbuf by as much
> > as 10 times.
>
> At least one of the reports shows problems with non e1000 NICs, so it's
> probably not just the e1000 change.
>
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=190620
>
> Ben
>
Wouldn't it be more likely commit 5d0b6f2bdaf7e016e750cd24164a241512d968a3

as this touches net/ipv4/tcp_output.c and is also in same general area?
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand

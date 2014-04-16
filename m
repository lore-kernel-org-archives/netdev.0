From: Dongsheng Song <dongsheng.song@gmail.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Wed, 16 Apr 2014 16:39:40 +0800
Message-ID: <CAE8XmWqgcNAHcKnzdUamQ0T+NP27GKSiRv37JEHSQW-=1Fu=2w@mail.gmail.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com>
 <534C3DC2.9070604@gmail.com> <534E29D4.60100@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ext Vlad Yasevich <vyasevich@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>
To: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:59873 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbaDPIkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 04:40:01 -0400
In-Reply-To: <534E29D4.60100@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From my testing, netperf throughput from 600 Mbit/s drop to 6 Mbit/s,
the penalty is 99 %.

http://www.spinics.net/lists/linux-sctp/msg03308.html


On Wed, Apr 16, 2014 at 2:57 PM, Matija Glavinic Pecotic
<matija.glavinic-pecotic.ext@nsn.com> wrote:
>
> Hello Vlad,
>
> On 04/14/2014 09:57 PM, ext Vlad Yasevich wrote:
> > The base approach is sound.  The idea is to calculate rwnd based
> > on receiver buffer available.  The algorithm chosen however, is
> > gives a much higher preference to small data and penalizes large
> > data transfers.  We need to figure our something else here..
>
> I don't follow you here. Could you please explain what do you see as penalty?
>
> Thanks,
>
> Matija
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

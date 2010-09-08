From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Wed, 8 Sep 2010 12:32:57 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009081232060.26447@wel-95.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C4467E0.9080907@kernel.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1361224060-1283938377=:26447"
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56732 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab0IHJc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 05:32:59 -0400
In-Reply-To: <4C4467E0.9080907@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1361224060-1283938377=:26447
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 19 Jul 2010, Tejun Heo wrote:

> Hello,
> 
> On 07/16/2010 02:02 PM, Ilpo Järvinen wrote:
> > Besides, Tejun has also found that it's hint->next ptr which is NULL in 
> > his case so this won't solve his case anyway. Tejun, can you confirm 
> > whether it was retransmit_skb_hint->next being NULL on _entry time_ to 
> > tcp_xmit_retransmit_queue() or later on in the loop after the updates done 
> > by the loop itself to the hint (or that your testing didn't conclude 
> > either)?
> 
> Sorry about the delay.  I was traveling last week.  Unfortunately, I
> don't know whether ->next was NULL on entry or not.  I hacked up the
> following ugly patch for the next test run.  It should have everything
> which has come up till now + list and hint sanity checking before
> starting processing them.  I'm planning on deploying it w/ crashdump
> enabled in several days.  If I've missed something, please let me
> know.

Any news on this one?

-- 
 i.
--8323329-1361224060-1283938377=:26447--

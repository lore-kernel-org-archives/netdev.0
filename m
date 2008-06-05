From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ipv6 addrconf: Ignore requests to set NODAD flag when changing addresses
Date: Thu, 5 Jun 2008 22:14:10 +0200
Message-ID: <20080605201410.GM20815@postel.suug.ch>
References: <20080604234751.GH20815@postel.suug.ch> <20080605.115314.80065467.yoshfuji@linux-ipv6.org> <20080605090447.GL20815@postel.suug.ch> <20080605.233256.53155823.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@ml.linux-ipv6.org,
	nakam@gomagoma.org, takamiya@po.ntts.co.jp
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59652 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909AbYFEUNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 16:13:50 -0400
Content-Disposition: inline
In-Reply-To: <20080605.233256.53155823.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2008-06-05 23:32
> In article <20080605090447.GL20815@postel.suug.ch> (at Thu, 5 Jun 2008 11:04:47 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > * YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> 2008-06-05 11:53
> > > And well, it does not take effect so far, but 
> > > DAD after link failure logic is planned in long term.
> > > So current code is okay to me.
> > 
> > Alright, that makes sense if that code ever is written.
> > 
> > I'm not sure I understand your new patch though, why do you want to
> > disable setting the nodad flag for new addresses nowW?
> 
> If we should really need to avoid the confusion, we have an option
> to disallow modification of NODAD flag so far with the patch I've posted.
> But anyway, I'm going to leave it as-is if you are okay.

Your patch would have disabled the ability to even add new addresses
with the NODAD flag set, that's what confused me. I'm fine with
leaving everything as-is since you explained that DAD will be done
after link failures in the future.

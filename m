From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 3/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 14:18:48 +0100
Message-ID: <200512141418.48388.netdev@axxeo.de>
References: <Pine.LNX.4.58.0512140052470.31720@w-sridhar.beaverton.ibm.com> <1134559039.25663.12.camel@localhost.localdomain> <20051214121253.GB23393@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Sridhar Samudrala <sri@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932500AbVLNNSd@vger.kernel.org>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20051214121253.GB23393@gaz.sfgoth.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr wrote:
> Alan Cox wrote:
> > > +#define SK_CRIT_ALLOC(sk, flags) ((sk->sk_allocation & __GFP_CRITICAL) | flags)
> > 
> > Lots of hidden conditional logic on critical paths.
> 
> How expensive is it compared to the allocation itself?

Cost is readability here. You should open code this additional OR


Regards

Ingo Oeser

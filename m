From: reinette chatre <reinette.chatre@intel.com>
Subject: Re: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 14:08:15 -0700
Message-ID: <1274821695.2091.16878.camel@rchatre-DESK>
References: <20100525170401.GE31753@tuxdriver.com>
	 <AANLkTilMYGSprjMnmRHlZPMvk1KLd1Yeqd_l26yyVRT6@mail.gmail.com>
	 <4BFC2677.7050509@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	Sedat Dilek <sedat.dilek@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Backlund <tmb@mandriva.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59877 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934273Ab0EYVI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 17:08:28 -0400
In-Reply-To: <4BFC2677.7050509@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 12:35 -0700, Thomas Backlund wrote:
> 25.05.2010 22:23, Sedat Dilek skrev:
> > "[1/2] iwlwifi: fix internal scan race" [1] is in this pull request.
> > Isn't "[2/2] iwlagn: work around rate scaling reset delay" [2] missing?
> > IIRC, both fixes were sent as a double-patch.
> >
> 
> It's already upstream:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=3bce6066263efb5733ee2141ac8b56684fb3b0a7

Yes, thank you, [2] was sent upstream (targeting 2.6.35) a while ago but
was later determined to be needed in 2.6.34 also. That is why it was
sent together with another fix targeting 2.6.34 ... both were sent
before 2.6.34 was released in the hopes that they will make it into
2.6.34. Unfortunately these patches did not make it into 2.6.34 and with
[2] already in 2.6.35 only [1] needed to be added there. 

We will now have to send these patches to stable to get them into
2.6.34.

Reinette



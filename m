From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V2 04/10] net/act_skbedit: Utility functions for
 mark action
Date: Thu, 3 Mar 2016 21:58:21 +0200
Message-ID: <20160303195821.GC15037@office.Home>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-5-git-send-email-amir@vadai.me>
 <CAM_iQpVO9BjUw8ZB0tnmH+a18DkrAVjNdth5R5xuzmS9gPJRuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36216 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbcCCTyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 14:54:10 -0500
Received: by mail-wm0-f66.google.com with SMTP id l68so650663wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 11:54:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVO9BjUw8ZB0tnmH+a18DkrAVjNdth5R5xuzmS9gPJRuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 09:48:40AM -0800, Cong Wang wrote:
> On Thu, Mar 3, 2016 at 6:55 AM, Amir Vadai <amir@vadai.me> wrote:
> > +static inline bool is_tcf_skbedit_mark(const struct tc_action *a)
> > +{
> > +#ifdef CONFIG_NET_CLS_ACT
> > +       if (a->ops && a->ops->type == TCA_ACT_SKBEDIT)
> > +               return to_skbedit(a)->flags == SKBEDIT_F_MARK;
> 
> 
> You mean to_skbedit(a)->flags & SKBEDIT_F_MARK ?
I will add a comment in v3 - it is on purpose. The function return true
iff the function is mark - other actions should not be offloaded.

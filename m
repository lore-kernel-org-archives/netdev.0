From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Patch net v3 5/5] net_sched: convert tcf_exts from list to
 pointer array
Date: Tue, 16 Aug 2016 12:54:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00DFFCA@AcuExch.aculab.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470962503-19682-6-git-send-email-xiyou.wangcong@gmail.com>
 <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Jamal Hadi Salim' <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:63131 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368AbcHPM5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 08:57:18 -0400
In-Reply-To: <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim
> Sent: 13 August 2016 12:34
> 
> Just minor comment below:
> 
> On 16-08-11 08:41 PM, Cong Wang wrote:
> 
> 
> > +static inline void
> > +tcf_exts_to_list(const struct tcf_exts *exts, struct list_head *actions)
> > +{
> 
> to:
> static inline void tcf_exts_to_list(const struct tcf_exts *exts,
>                                      struct list_head *actions)

It may not be the 'Linux style' but I much prefer the former since it
makes 'grep -r '^tcf_exts_to_list\>' find the definition.

	David

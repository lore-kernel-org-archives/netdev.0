From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Tue, 26 Sep 2006 13:09:59 -0700 (PDT)
Message-ID: <20060926.130959.90119692.davem@davemloft.net>
References: <1159255520.2782.1.camel@ux156>
	<20060926094408.GT18349@postel.suug.ch>
	<1159265074.2782.13.camel@ux156>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13528
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932262AbWIZUJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 16:09:55 -0400
To: johannes@sipsolutions.net
In-Reply-To: <1159265074.2782.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 26 Sep 2006 12:04:34 +0200

> On Tue, 2006-09-26 at 11:44 +0200, Thomas Graf wrote:
> 
> > Thinking it over I'm still not completely happy with this. A
> > small subset of all the validation tasks is simply too complex
> > to be put into the policy. The validation of your type value
> > array is such a case, address fields with variable length based
> > on their family is another. I think it's just not worth to
> > blow up struct nla_policy by 12 bytes per entry just to save
> > some code.
> 
> Alright, I can instead just add the validation function call wherever
> that attribute is going to be used. Just thought it might be nice to
> have this generically, I'm not really too attached to it :)
> 
> I'll change it in the next nl80211 iteration.

Thanks Johannes.

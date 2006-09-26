From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Tue, 26 Sep 2006 12:04:34 +0200
Message-ID: <1159265074.2782.13.camel@ux156>
References: <1159255520.2782.1.camel@ux156>
	 <20060926094408.GT18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37310 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751005AbWIZKDt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:03:49 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060926094408.GT18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-26 at 11:44 +0200, Thomas Graf wrote:

> Thinking it over I'm still not completely happy with this. A
> small subset of all the validation tasks is simply too complex
> to be put into the policy. The validation of your type value
> array is such a case, address fields with variable length based
> on their family is another. I think it's just not worth to
> blow up struct nla_policy by 12 bytes per entry just to save
> some code.

Alright, I can instead just add the validation function call wherever
that attribute is going to be used. Just thought it might be nice to
have this generically, I'm not really too attached to it :)

I'll change it in the next nl80211 iteration.

johannes

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 12:37:13 -0800
Message-ID: <20070212123713.1e8efb0d@freekitty>
References: <20070212160336.681729431@linux-foundation.org>
	<20070212191101.GP25760@galon.ev-en.org>
	<5640c7e00702121213p1430891el76e259aacd517c4a@mail.gmail.com>
	<20070212.123240.21597176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41420 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965365AbXBLUh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 15:37:29 -0500
In-Reply-To: <20070212.123240.21597176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Feb 2007 12:32:40 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
> Date: Tue, 13 Feb 2007 09:13:52 +1300
> 
> > Unless of course the papers you saw at PFLDNET showed that Cubic was a
> > really good choice and you want to point us to those papers.
> 
> I heavily dislike all of these "reactionary" patches from Stephen
> after he attended PFDLNET.
> 
> If he never went there, none of these patches would have been
> proposed.  He went to the sermon and he became converted :-)

My patches weren't reactionary. Going to pure old Reno is reactionary.
It was more looking at the state of the code on the flight back
and cleaning house. Others were/are reactionary. 


> We want people to play with this stuff, and they can experiment
> regardless of whatever options or even code we put into the kernel.
> Every user can muck with the congestion control on their computer
> however they want, and THAT'S GOOD!
> 
> Sure we indirectly recommend to distribution vendors what to use
> by default by the Kconfig defaults we put into the vanilla tree,
> and that's fine too.
> 
> Even after reading all of the papers, I still think CUBIC or even BIC
> by default is not all that controbersal or radical thing to use by
> default.
> 
> I'm sorry if the researchers and IETF folks don't like this.  Too bad,
> get over it.

I push the problem back in their court: "Why do you not have a process
that causes consensus?" IETF has done nothing to create any incentive
for long term cooperation.

> If you use RENO you're stupid, since performance is going to stink for
> absolutely normal connections.  Fact: high BDP pipes are everywhere,
> even grandma has one.  So just taking out the best solution we have
> for that problem currently because it's not perfect is not the answer.
> 

Do I need to dig out the "Why Reno sucks" graphs?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] string matching ematch
Date: Tue, 01 Feb 2005 02:26:07 +0100
Message-ID: <41FEDAAF.5090201@eurodev.net>
References: <20050126150714.GL31837@postel.suug.ch>	 <41F94C63.7010800@eurodev.net>  <20050127205147.GS31837@postel.suug.ch> <1107179994.7840.164.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com, Harald Welte <laforge@netfilter.org>
To: hadi@cyberus.ca
In-Reply-To: <1107179994.7840.164.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,

Harald, I've cc'ed you since I think that this could be interesting.

jamal wrote:

>I think we should allow for all sorts of algrithms KMP, Boyer-Moore etc
>to be plugged in (in tc this is already there).
>The stuff that Harald was looking at (at least around July when i last
>talked to him on this) is an infrastructure level thing. Its derived
>from someone who seems to have well thought of the callbacks etc for a
>good stateful solution. I cant remember the person from whom Harald was
>deriving his stuff (email was somewhere in .fr) - but it did seem pretty
>sensible.
>

yes, Phil Biondi's libqsearch. I started working with it but then I 
thought that it was a bit bloated because I didn't see the point of 
using several algorithms since boyer-moore is the best AFAIK. But Thomas 
thoughts about memory usage made me see that maybe this doesn't fit well 
all possible scenarios. So I've changed my mind and I think that such 
infrastructure level thing is required.

Harald told me that he's going to finish soon his hacks based on 
libqsearch, then we could merge ideas based in that thing I've posted 
after christmas and his libqsearch mutant.

> If we can have infrastructure that is also usable by tc, that
>would be great so we dont go cutnpasting unnecessarily.
>  
>

definitely.

>Having said all that:
>Thomas, I think you should leave what you have as totaly stateless
>unless we dont have a shareable solution. I have tons of ideas i could
>share when we get to that level.
>  
>
I've got also some ideas, let's see if I can get settled one of them at 
least after the infrastructure have been cooked :).

--
Pablo

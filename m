From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Mon, 19 Apr 2004 14:33:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wazza.87smf0jgfn.fsf@message.id>
References: <407E5905.9070108@dsl.pipex.com>
	<1082031313.1039.13.camel@jzny.localdomain>
	<407EE3E5.8060200@dsl.pipex.com>
	<1082087553.1035.287.camel@jzny.localdomain>
	<4080356F.4020609@dsl.pipex.com>
	<1082145341.1026.125.camel@jzny.localdomain>
	<40810957.6030209@dsl.pipex.com>
	<1082203795.1043.18.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082203795.1043.18.camel@jzny.localdomain> (hadi@cyberus.ca's
 message of "17 Apr 2004 08:09:55 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[...]
> - packets from local Lan can be marked at ingress and redirect to a
> dummy if needed. Infact you can do this on the egress at ppp0 as well
> using the new tc -i <inputdev> that i introduced. So this is easy.

Hmm I don't see -i option in the patches.
what's the point of having a -i <inputdev> option ?
does it mean I can work on egress at ppp0 and use -i eth0 to match packets
that were originaly from eth0 ?
I personnaly use netfilter to mark packets and 'handle $mark fw' to
filter them. (that may explain why i don't see the point :-)

-- 

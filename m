From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Wed, 21 May 2003 10:46:50 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3ECB9F6A.20004@ethanet.com>
References: <Pine.LNX.4.44.0305211447270.12543-100000@deneb.intranet.cartel-securite.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <Pine.LNX.4.44.0305211447270.12543-100000@deneb.intranet.cartel-securite.net>
To: Philippe Biondi <biondi@cartel-securite.fr>
List-Id: netdev.vger.kernel.org

Philippe Biondi wrote:

>regexp support was planned but not done yet. (if someone know where I can
>download more free time !).
>
>The implementation should not be that hard, once you have the compiler to
>transform the string describing the regexp to an automaton.
>
>Note that to respect the framework, you have to deal with multiple
>patterns (should not be that hard). If you have pat1 and pat2, searching
>for (pat1|pat2) is not sufficient because for each match, you have to
>point which pattern matched.
>  
>

We actually planned on doing that initially. You should note that if you 
want to generate one automaton for multiple patterns, that is not a 
regular language (and thus can not be represented by a FA or DFA.)  You 
will have to try matching against the first pattern, then the next and 
so on.

Ethan


From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Options for ECN target
Date: Sat, 10 Aug 2002 10:21:56 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208101019130.3494-100000@shell.cyberus.ca>
References: <20020806083541.L11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20020806083541.L11828@sunbeam.de.gnumonks.org>
List-Id: netdev.vger.kernel.org



The last 3 options are dangerous; although i am pretty sure it is too
late to complain about it since you have released the code at least once.
When ECN nonces comes into effect, it may become a non-issue (but would
still make interesting effect).
suggestion: get rid of them.

cheers,
jamal

On Tue, 6 Aug 2002, Harald Welte wrote:

>
> There is one question left: How much flexibility do we want to give the user?
>
> The ECN target currently allows:
>
> --ecn-tcp-remove	Remove CWR+ECE bits from TCP header. Should be used
> 			on TCP syn packets to prevent ECN negotiation
>
> --ecn-ip-ect [0..3] 	Allows arbitrary setting of the ECT codepoint
> --ecn-tcp-cwr [0|1]	Allows setting or clearing the TCP CWR bit
> --ecn-tcp-ece [0|1]	Allows setting or clearing the TCP ECE bit
>
>
> The first option is necessarry and is the primary use of the target.
> The last three options are more experimental and would allow somebody
> to play with 'simulated congestion' by setting the ECT in IP, etc.
>
> However, this is potentially very dangerous and I'm not sure if it was
> a good idea to give this power directly to the user.
>
> Do you suggest removing the last three options and just keep the
> --ecn-tcp-remove ?
>
> Thanks for your assistance,
>
> --
> Live long and prosper
> - Harald Welte / laforge@gnumonks.org               http://www.gnumonks.org/
> ============================================================================
> GCS/E/IT d- s-: a-- C+++ UL++++$ P+++ L++++$ E--- W- N++ o? K- w--- O- M+
> V-- PS++ PE-- Y++ PGP++ t+ 5-- !X !R tv-- b+++ !DI !D G+ e* h--- r++ y+(*)
>

From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP sockopt discrepancy between 2.4 and 2.6.
Date: Mon, 2 Feb 2004 11:09:21 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402021056290.2352@localhost.localdomain>
References: <1075747382.786.366.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, marcelo.tosatti@cyclades.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1075747382.786.366.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, David Woodhouse wrote:

> The 2.4 and 2.6 SCTP code have _different_ values for the SCTP_*
> sockopts. The 2.4 version claims to implement
> draft-ietf-tsvwg-sctpsocket-04.txt while the 2.6 version implements
> draft-ietf-tsvwg-sctpsocket-07.txt.

I think 2.4 lksctp is compatible with draft-iets-tsvwg-sctpsocket-06.txt.

>
> This means that tools compiled with the current libraries and header
> files cannot work on the 2.4 kernel.

Right. The latest lksctp-tools(lksctp-tools-2.6.0-test7-0.7.4) will not work
with 2.4. An earlier version(lksctp-tools-2_5_67-0_6_9) may work with 2.4.

>
> Am I missing something -- like perhaps the existence of a patch to
> update the 2.4 kernel -- or is the SCTP implementation in 2.4 no longer
> being maintained, and no longer compatible with 2.6 and its userspace?

2.4 lksctp implementation is a backport from 2.6(the backport originally was
done from 2.5.69). The backport process should have continued and kept up with
the 2.6 changes. But due to resource problems, it is not happening.
2.6 lksctp is under active development and is compatible with the latest
SCTP sockets api draft(ver 07).

Are you interested in a 2.4 version of lksctp?

Thanks
Sridhar

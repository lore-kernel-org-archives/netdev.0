From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Sun, 13 Oct 2002 16:30:34 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210131610010.26803-100000@shell.cyberus.ca>
References: <200210131914.XAA09216@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200210131914.XAA09216@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Look at RFC 2863 section 3.1.12; there is some description on operational
status. At the moment the only status is IFF_RUNNING in the ifi_flags.
So the question was could we use ifi_change to send the other pieces of
info (as per RFC 2863)  and as implemented in Stefans patch?
If not, could we take advantage of that pad in the ifinfomsg? This should
not break any backward compatibility.

cheers,
jamal

On Sun, 13 Oct 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > How about making use of ifi_change to extend them? Alexey, would this be
> > proper use of ifi_change?
>
> I did not understand the question.
>
> Alexey
>

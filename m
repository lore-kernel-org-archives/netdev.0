From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: TCP hangs --- zero window probes
Date: Tue, 4 May 2004 18:28:33 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405041827480.11971@artax.karlin.mff.cuni.cz>
References: <200405041525.UAA21109@shilpa.india.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Praveen Kumar Amritaluru <praveen@india.hp.com>
In-Reply-To: <200405041525.UAA21109@shilpa.india.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hi,
>
> 	I raised a similar issue sometime back on this mailing list.  It
> 	is basically non-conformance of RFC.
>
> 	Its not that  Linux is  sending  ACK only  packets  rather it is
> 	sending an unacceptable ACK segment forcing the receiver to send
> 	an ACK.  Use Ethereal to view the ACK  segments  since that will
> 	show the sequence no.  as well.
>
> 	I feel that it is a bug, but others may not feel the same way.
>
> 	The clarification/justification I heard in this mailing-list was
> 	that  "this  implementation  is more  interoperable  with  other
> 	implementations"  compared to "sending  zero  window  probes" as
> 	defined in RFC793/RFC1122.
>
>
> Regards,
>
> Praveen

Yes. I fixed the client so that it sends ACKs if it receives ACK with
non-matching seq number.

Mikulas

From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 10:14:04 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210011010010.18461-100000@shell.cyberus.ca>
References: <200210011353.RAA19504@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@sun.com>,
   Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200210011353.RAA19504@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey,

I agree; so just ignore the patch. You know you could have saved me
about an hour if you spoke earlier ;->
Eric, note what Alexey says. So to get enobufs please
use the sockoption to set IP_RECVERR
Someone should document this in the manpages.

cheers,
jamal

On Tue, 1 Oct 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > be propagated back to the socket level; please review and probably
> > apply:
>
> That was tried and failed miserably ages ago. Applications become
> insane when getting this error from logging tons of useless messages
> to abort()ing and cpu hogging. From the other hand silent reaction
> to loss is almost exactly desired behaviour in presence of congestion
> in the most of cases.
>
> I have no idea, why that OSes work. Probably, they are so great that
> never lose packets. We do.
>
> Probably, the world has changed since that time, but I have no desire
> to repeat the experiment to be honest.
>
> Alexey
>
>
>

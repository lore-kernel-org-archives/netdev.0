From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 09:01:50 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210140851220.26803-100000@shell.cyberus.ca>
References: <200210132204.CAA09385@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200210132204.CAA09385@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 14 Oct 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > Actually the extra flags are only valid when IFF_RUNNING is not set.
>
> Even so...
>
> Well, then I am inclined not to agree to give even one of those valuable
> 16 spare bits for this. :-)
>
> I cannot imagine how much should I drink to consider states descibed
> in this rfc as a valid abstraction. Device can be working and can be dead
> by thousands of reasons. The best which I can propose is to show a string
> somewhere in /proc (well, or as a _string_ attribute in RTM_NEWLINK),
> explaining why device is not alive and let snmpd to translate this string
> to these bogus states to generate traps.

;-> Believe it or not people use these things to draw nice GUI
representations (search for lowerLayerDown at cisco for example);
how we represent them shouldnt matter whether its via ifi_flags, /proc
etc. Infact it should also be fine if we dont propagate them to user space
for now, but the abstraction should stay in the kernel at least.

cheers,
jamal

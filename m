From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Wed, 10 Jul 2002 19:34:02 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca>
References: <20020710223237.GA7995@orr.falooley.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <Robert.Olsson@data.slu.se>,
   <greearb@candelatech.com>, <garzik@mandrakesoft.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20020710223237.GA7995@orr.falooley.org>
List-Id: netdev.vger.kernel.org



For some reason i thought there was already patches for 2.4.18 and above.
Robert, seems like you dont have them;
Two patches:
2.4.18: http://www.cyberus.ca/~hadi/patches/napi-patch-2418.gz
2.4.19-pre10: http://www.cyberus.ca/~hadi/patches/napi-2419-pre10.gz

Also a more recently tested tulip driver at:
http://www.cyberus.ca/~hadi/patches/tulip-napi.tgz
tested with Znyx 4 port ethernet cards;
For the best perfomance (at least on the Znyx Nics) turn on MMIO
(selected from kernel config). Ignore anything that looks strange
in the code. The dl2k and sundance driver from Ed Peng listed in the
README at the site should work fine on 2.4

The info is at:
ftp://robur.slu.se/pub/Linux/net-development/NAPI/README

cheers,
jamal

On Wed, 10 Jul 2002, Jason Lunz wrote:

>
> I've backported the most recent napi sources I could find to 2.4.19-rc1.
> The patches are available at http://orr.falooley.org/pub/linux/net/.
>
> Testing and suggestions are welcome. Currently backported napi drivers
> are e1000, eepro100, tulip, and 3c59x. I intend to backport dl2k and
> sundance at some point, but I have no dl2k cards and I'm working with
> Donald Becker to get the sundance driver working on the card I have.
>
> Does anyone know of more recent NAPI conversions? Robert Olsson tells me
> Jeff Garzik has a more recent tulip conversion, but there are _no_ napi
> net drivers in 2.5.25 and I haven't found any others except for those
> mentioned at the NAPI ftp site.
>
> Jason
>

From: jamal <hadi@cyberus.ca>
Subject: Re: IP stack question
Date: Mon, 24 Jun 2002 09:34:47 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0206240922230.12806-100000@shell.cyberus.ca>
References: <180577A42806D61189D30008C7E632E8793946@boca213a.boca.ssc.siemens.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Bloch, Jack" <Jack.Bloch@icn.siemens.com>
In-Reply-To: <180577A42806D61189D30008C7E632E8793946@boca213a.boca.ssc.siemens.com>
List-Id: netdev.vger.kernel.org


I tried to explain to you in private mail:
Both 10.1.1.4 and 10.1.1.5 are recognized to be local addresses
by the IP stack. It is legit that the stack limits the scope
to just that i.e _local_
 The only way to do what you want to do is bypass the IP stack.
Use packet socket to write your  test app.
(which actually probably defetas the whole purpose of what you may
be trying to do -- HA).

cheers,
jamal

On Mon, 24 Jun 2002, Bloch, Jack wrote:

> I am writing this e-mail at the recommendation of Alan Cox. I have an
> embedded system running on cPCI HW which has two physical Ethernet
> connections. This system is connected to an internal network and the IP
> addresses are not made public. I use the IP addresses 10.1.1.4 and 10.1.1.5
> respectively. The two physical ports are connected to two separate LAN
> switches which are connected by an uplink. I want to periodically test this
> uplink cable. My plan to do this is to send a simple test message (much like
> a ping) from 10.1.1.4 to 10.1.1.5, however, the IP stack does not let me do
> this. Is there any specific reason why not?
>
> Jack Bloch
> Siemens Carrier Networks
> e-mail    : jack.bloch@icn.siemens.com
> phone     : (561) 923-6550
>

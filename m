From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Virtual Routing and Forwarding
Date: Tue, 22 Oct 2002 21:11:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222107060.24323-100000@shell.cyberus.ca>
References: <20021021223810.A23086@nero.doit.wisc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "James R. Leu" <jleu@mindspring.com>
In-Reply-To: <20021021223810.A23086@nero.doit.wisc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think you are mucking with too many things. heres some thoughts:
- use aliases
- tag skbs based on which local aliases they arrived destined to and
send them to the right VR
- use multi routing table feature already available on linux

Of course this is the easy part. Separation of VRs is going to be the
challenge (talking about CPU and memory isolation - such that for example
gated for VR1 doesnt talk to gated for VR2)

cheers,
jamal

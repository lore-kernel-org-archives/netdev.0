From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 15:20:56 +0300
Message-ID: <200810071520.56610.denys@visp.net.lb>
References: <20081006202401.14f03be2@speedy> <48EACA2A.1030005@candelatech.com> <48EB488A.40409@trash.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_oQ16IY6FfBo6OFW"
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:39856 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbYJGMXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:23:04 -0400
In-Reply-To: <48EB488A.40409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_oQ16IY6FfBo6OFW
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Probably to make people use iproute2, it is good to inform them, that iproute2 
can do that job. 

For example i didn't knew that ip can make vlan's and etc.
And even embedded help doesn't help almost.

Something like attached trivial patch, at least will give idea, what to do.

man page i can edit too, but i guess it is better someone with good english 
will do that.

On Tuesday 07 October 2008, Patrick McHardy wrote:
> Ben Greear wrote:
> > Patrick McHardy wrote:
> >> Actually I don't maintain vconfig and I don't think Ben does either.
> >> Its deprecated and iproute is what people should use, all the new
> >> features are not supported by vconfig.
> >
> > I can fix these things if anyone cares, but leaving it crufty might be a
> > better way to encourage folks to use 'ip'.
>
> I think it would make sense to add a note to the manpage
> or something like that. Maybe also a runtime warning in
> case its really (going to be) unmaintained.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--Boundary-00=_oQ16IY6FfBo6OFW
Content-Type: text/plain;
  charset="iso-8859-15";
  name="iproute_linkhelp_rfc.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iproute_linkhelp_rfc.txt"

diff -Naur iproute2.backup/ip/iplink.c iproute2/ip/iplink.c
--- iproute2.backup/ip/iplink.c	2008-10-05 15:41:59.000000000 +0000
+++ iproute2/ip/iplink.c	2008-10-07 12:14:28.000000000 +0000
@@ -54,6 +54,10 @@
 	fprintf(stderr, "	                     mtu MTU }\n");
 	fprintf(stderr, "	                     netns PID }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
+	fprintf(stderr, "       ip link add link PARENTDEV type { vlan | veth } { ... | help }\n");
+	fprintf(stderr, "       ip link add link PARENTDEV NEWDEVICE type macvlan { ... | help }\n");
+	fprintf(stderr, "       ip link change link PARENTDEV type { vlan | veth } { ... | help}\n");
+	fprintf(stderr, "       ip link del dev DEVICE\n");
 	exit(-1);
 }
 

--Boundary-00=_oQ16IY6FfBo6OFW--

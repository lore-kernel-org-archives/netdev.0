From: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 14:08:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <012b01c36581$6fd1c1b0$c801a8c0@llewella>
References: <20030728213933.F81299@coredump.scriptkiddie.org><200308171509570955.003E4FEC@192.168.128.16><200308171516090038.0043F977@192.168.128.16><1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk><200308171555280781.0067FB36@192.168.128.16><1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk><200308171759540391.00AA8CAB@192.168.128.16><1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk><200308171827130739.00C3905F@192.168.128.16><1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk><20030817224849.GB734@alpha.home.local><20030817223118.3cbc497c.davem@redhat.com> <20030818133957.3d3d51d2.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <willy@w.ods.org>, <alan@lxorguk.ukuu.org.uk>, <carlosev@newipnet.com>,
   <lamont@scriptkiddie.org>, <davidsen@tmr.com>, <marcelo@conectiva.com.br>,
   <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>, <layes@loran.com>,
   <torvalds@osdl.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Replying again... Alan does mention in the paragraph you've quoted
> > to use arpfilter, which works for every case imaginable.
No it doesn't. When I have two nics on DHCP on the same ethernet segment, it
cannot be made to work. I don't know the ip addresses beforehand. And if if
I would get them with scripting and crafted some rules on the fly, there's
no way I can be sure I'll get the same IP's on a renew, so I'd have to check
often.

Regards,
Bas

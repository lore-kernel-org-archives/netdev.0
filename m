From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 17 Aug 2003 16:28:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
	 <20030728213933.F81299@coredump.scriptkiddie.org>
	 <200308171509570955.003E4FEC@192.168.128.16>
	 <200308171516090038.0043F977@192.168.128.16>
	 <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
	 <200308171555280781.0067FB36@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lamont Granquist <lamont@scriptkiddie.org>,
   Bill Davidsen <davidsen@tmr.com>, "David S. Miller" <davem@redhat.com>,
   bloemsaa@xs4all.nl, Marcelo Tosatti <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200308171555280781.0067FB36@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2003-08-17 at 14:55, Carlos Velasco wrote:
> >> According to RFC 1027:
> >> http://www.ietf.org/rfc/rfc1027.txt
> >
> >Proxy ARP only.
> 
> So, if you have a router performing Proxy ARP... you don't need to
> reply to the "bad" Linux ARP Request, right?

Linux doesn't issue "bad" requests. Linux will reply when it is
asked for an address that it owns, as per RFC826, unless you chose
to change the behaviour with things like arpfilter.

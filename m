From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 11:30:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241130.53262.bdschuym@pandora.be>
References: <Pine.LNX.4.44.0307240149480.1181-100000@u.domain.uli> <200307240134030339.1EADABD4@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>, "Julian Anastasov" <ja@ssi.bg>
In-Reply-To: <200307240134030339.1EADABD4@192.168.128.16>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 24 July 2003 01:34, Carlos Velasco wrote:
> >http://sourceforge.net/projects/ebtables/
> >http://www.ssi.bg/~ja/#iparp
>
> I didn't know about these tools.
> I have taken a look on them, but they seem to be used for arp filtering?
> I can't see how these tools can help me into this.

arptables can mangle the arp payload with the "mangle" module. You'll need a 
very recent kernel for this, net/ipv4/netfilter/arpt_mangle.c must exist. The 
userspace code for this is in the CVS at the mentioned site, I haven't made a 
new release yet due to lack of time.

cheers,
Bart

From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Fri, 17 Oct 2003 01:48:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016234847.GA17048@vana.vc.cvut.cz>
References: <32A9D366A0B@vcnet.vc.cvut.cz> <20031016152136.50e2a389.davem@redhat.com> <1066344060.2232.9.camel@localhost.localdomain> <20031016154537.2bcf7404.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031016154537.2bcf7404.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2003 at 03:45:37PM -0700, David S. Miller wrote:
> On Thu, 16 Oct 2003 15:41:00 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > On Thu, 2003-10-16 at 15:21, David S. Miller wrote:
> > vmware wasn't just trying to influence, it used the implementation.
> 
> It just so happened to be usable in this way.
> 

I do not understand. At least on hardware and configurations I tested
code still works if I set af_packet_priv member to some non-NULL value.
It looked to me like that it is not intentional that ARP replies are not
delivered to the sniffer - from your reply it looks to me like that
only allowed user  of whole packet_type, not only af_packet_priv member,
is AF_PACKET, and that for correct functionality af_packet_priv member
must be non-NULL. Otherwise semantic of this call is ungrokable by
me (it is ungrokable anyway as vital information where checksum should
be placed is lost, but you already said that it is intentional that tcpdump
sees it wrong).

For now I understand that I should set af_packet_priv to non-NULL value.
						Best regards,
							Petr Vandrovec
							vandrove@vc.cvut.cz

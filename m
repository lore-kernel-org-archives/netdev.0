From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Thu, 16 Oct 2003 23:55:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016235529.1a0cded0.davem@redhat.com>
References: <32A9D366A0B@vcnet.vc.cvut.cz>
	<20031016152136.50e2a389.davem@redhat.com>
	<1066344060.2232.9.camel@localhost.localdomain>
	<20031016154537.2bcf7404.davem@redhat.com>
	<20031016234847.GA17048@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031016234847.GA17048@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Oct 2003 01:48:47 +0200
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

> It looked to me like that it is not intentional that ARP replies are not
> delivered to the sniffer - from your reply it looks to me like that
> only allowed user  of whole packet_type, not only af_packet_priv member,
> is AF_PACKET, and that for correct functionality af_packet_priv member
> must be non-NULL.

I relooked at this, and you may have a point.  Let me study
this some more.

Thanks.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Thu, 16 Oct 2003 15:21:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016152136.50e2a389.davem@redhat.com>
References: <32A9D366A0B@vcnet.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Petr Vandrovec" <VANDROVE@vc.cvut.cz>
In-Reply-To: <32A9D366A0B@vcnet.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003 12:07:23 +0200
"Petr Vandrovec" <VANDROVE@vc.cvut.cz> wrote:

> It behaves same way it behaved. But recently you renamed packet_type.data
> to packet_type.af_packet_priv, saying that af_packet_priv should be used
> only by AF_PACKET code, by nobody else. So I trusted you, removed
> packet_type.data (and packet_type.af_packet_priv) references from the
> code - and things stopped working, as with af_packet_priv==NULL ARP
> replies are not delivered to the registered packet_type callback, as
> these packets match skb->sk == pt->af_packet_priv for af_packet_priv == NULL.

vmware was trying to influence the behavior of input packet
delivery by setting ->data in a way which was never defined.
That facility existed and continues to exist for the sake
of AF_PACKET solely, what vmware was doing just happened to work.

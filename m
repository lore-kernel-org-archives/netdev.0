From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Wed, 15 Oct 2003 20:47:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015204704.06637fbe.davem@redhat.com>
References: <20031015171112.GA2469@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031015171112.GA2469@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 19:11:12 +0200
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

>   after recent changes in packet_type interface I stopped setting
> af_packet_priv - as you told that it is only for AF_PACKET, for nobody
> else. And - things stopped working.

"Where" did you stop doing this?

Nothing in the current kernel should be broken at all by said
changes I did to 2.6.x

If it has broken something you are working on external to the tree
you have to say what it is.  I can only guess that it's making
assumptions that never truly existed.

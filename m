From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][SELINUX] 2/2 sock_create_lite()
Date: Sat, 8 May 2004 15:04:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040508150432.3856573c.davem@redhat.com>
References: <Xine.LNX.4.44.0405071118490.21529-100000@thoron.boston.redhat.com>
	<Xine.LNX.4.44.0405071531480.22499-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, sds@epoch.ncsc.mil, chrisw@osdl.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        selinux@tycho.nsa.gov
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0405071531480.22499-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 May 2004 15:53:30 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> Ok, here's a version of this patch which doesn't do anything with 
> sock_alloc().

Applied, although I had to hand-edit the patch since you
accidently included the following bit from the first SELINUX
patch of this series :-)

> -	err = sock_create(family, SOCK_SEQPACKET, IPPROTO_SCTP,
> -			  &sctp_ctl_socket);
> +	err = sock_create_kern(family, SOCK_SEQPACKET, IPPROTO_SCTP,
> +			       &sctp_ctl_socket);

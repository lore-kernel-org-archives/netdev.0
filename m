From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] work around 5701 misalignment
Date: Tue, 19 Oct 2004 23:15:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019231537.57e8ad10.davem@davemloft.net>
References: <200410131554.19845.jbarnes@sgi.com>
	<416D96B8.5090204@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbarnes@sgi.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <416D96B8.5090204@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2004 16:57:28 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> DaveM might squirm a bit but IMHO RX_COPY_THRESHOLD really is 
> platform-dependent.

I'm not totally against such an idea.
We have something similar already in the form
of NET_IP_ALIGN which ppc64 overrides.

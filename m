From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make SO_BINDTODEVICE bind very tightly
Date: Wed, 8 Oct 2003 04:49:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008044948.4e3bdf3c.davem@redhat.com>
References: <3F833B39.4020606@Carter.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Casey Carter <Casey@Carter.net>
In-Reply-To: <3F833B39.4020606@Carter.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Oct 2003 17:16:25 -0500
Casey Carter <Casey@Carter.net> wrote:

> In the presence of both sockets that are and sockets that are not bound 
> to a specific interface, those bound to the interface should always be 
> favored for packet delivery over those not so bound.

No, the fix made in the original posting of this thread is the
correct one.  One may not have some sockets with SO_BINDTODEVICE
and some with not bound at the same time to the same identity.
Therefore the fix should be a bind() time.

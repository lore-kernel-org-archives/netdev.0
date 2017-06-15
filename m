From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Fix several cases where a padded len isn't
 checked in ticket decode
Date: Thu, 15 Jun 2017 14:27:34 -0400 (EDT)
Message-ID: <20170615.142734.1952678170179907268.davem@davemloft.net>
References: <149748194451.23919.13232256832988154536.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149748194451.23919.13232256832988154536.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 15 Jun 2017 00:12:24 +0100

> This fixes CVE-2017-7482.
> 
> When a kerberos 5 ticket is being decoded so that it can be loaded into an
> rxrpc-type key, there are several places in which the length of a
> variable-length field is checked to make sure that it's not going to
> overrun the available data - but the data is padded to the nearest
> four-byte boundary and the code doesn't check for this extra.  This could
> lead to the size-remaining variable wrapping and the data pointer going
> over the end of the buffer.
> 
> Fix this by making the various variable-length data checks use the padded
> length.
> 
> Reported-by: 石磊 <shilei-c@360.cn>
> Signed-off-by: David Howells <dhowells@redhat.com>
> Reviewed-by: Marc Dionne <marc.c.dionne@auristor.com>
> Reviewed-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks David.

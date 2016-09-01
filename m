From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] rxrpc: Don't expose skbs to in-kernel
 users [ver #2]
Date: Thu, 01 Sep 2016 16:43:50 -0700 (PDT)
Message-ID: <20160901.164350.188976129063571139.davem@davemloft.net>
References: <147258609952.22464.8997026814758565636.stgit@warthog.procyon.org.uk>
        <147258612700.22464.16394006856318134180.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147258612700.22464.16394006856318134180.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 30 Aug 2016 20:42:14 +0100

> Don't expose skbs to in-kernel users, such as the AFS filesystem, but
> instead provide a notification hook the indicates that a call needs
> attention and another that indicates that there's a new call to be
> collected.
 ...
> Signed-off-by: David Howells <dhowells@redhat.com>

Ok, I tried this one instead.  If no warnings, I'll push it to net-next.

Thanks.

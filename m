From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] AFS: Adjust the new netdevice scanning code
Date: Thu, 03 May 2007 03:29:49 -0700 (PDT)
Message-ID: <20070503.032949.65795400.davem@davemloft.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
	<20070503095336.26912.55434.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: dhowells@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070503095336.26912.55434.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 03 May 2007 10:53:36 +0100

> Adjust the new netdevice scanning code provided by Patrick McHardy:
> 
>  (1) Restore the function banner comments that were dropped.
> 
>  (2) Rather than using an array size of 6 in some places and an array size of
>      ETH_ALEN in others, pass a pointer instead and pass the array size
>      through so that we can actually check it.
> 
>  (3) Do the buffer fill count check before checking the for_primary_ifa
>      condition again.  This permits us to skip that check should maxbufs be
>      reached before we run out of interfaces.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks.

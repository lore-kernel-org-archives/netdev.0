From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 29 Mar 2010 16:01:07 -0700
Message-ID: <4BB13133.6030500@zytor.com>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home> <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home> <20100322185310.GA20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322185310.GA20695@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2010 11:53 AM, Andi Kleen wrote:
> 
> There's just no portable atomic64_t. Ok maybe you can use the socket lock
> to synchronize all the counts if they are only per socket.
> 

In 2.6.34 there is (although some arches which could support it natively
don't as of yet... but that's fixable.)  See lib/atomic64.c.

	-hpa

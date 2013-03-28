From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 6/6] sctp: convert sctp_assoc_set_id to use
 idr_alloc_cyclic
Date: Thu, 28 Mar 2013 09:53:08 -0400
Message-ID: <20130328135308.GA14489@neilslaptop.think-freely.org>
References: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
 <1364412578-7462-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	tj@kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364412578-7462-7-git-send-email-jlayton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 27, 2013 at 03:29:38PM -0400, Jeff Layton wrote:
> (Note: compile-tested only)
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-sctp@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
>  net/sctp/associola.c | 16 ++--------------
>  1 file changed, 2 insertions(+), 14 deletions(-)
> 
I don't see anything wrong with this patch per-se, but the idr_alloc_cyclic call
isn't integrated with net/net-next or Linus' tree yet.  If we don't gate this
patch on that integration, we'll break the build.
Neil

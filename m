From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] use NETIF_F_LLTX in bonding device
Date: Tue, 22 Mar 2005 18:46:26 -0800
Message-ID: <20050322184626.543a78da.davem@davemloft.net>
References: <Pine.LNX.4.61.0503151016580.18478@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0503151016580.18478@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 10:29:16 -0800 (PST)
Arthur Kepner <akepner@sgi.com> wrote:

> 
> Lock contention on the bonding device's xmit_lock can 
> become a bottleneck when 3 or more gige links are aggregated. 
> And it looks like it's unnecessary too, so use the 
> NETIF_F_LLTX flag to avoid grabbing this lock. 
> 
> Signed-off-by: <akepner@sgi.com>

Yes, bonding does all of it's own internal locking, so this
change is correct.

Applied, thanks Arthur.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] lib: Ensure EWMA does not store wrong
	intermediate values
Date: Thu, 16 Jan 2014 12:08:47 -0800
Message-ID: <1389902927.31367.423.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389901950-3854-1-git-send-email-mwdalton@google.com>
	<1389901950-3854-5-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389901950-3854-5-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-16 at 11:52 -0800, Michael Dalton wrote:
> To ensure ewma_read() without a lock returns a valid but possibly
> out of date average, modify ewma_add() by using ACCESS_ONCE to prevent
> intermediate wrong values from being written to avg->internal.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
>  lib/average.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

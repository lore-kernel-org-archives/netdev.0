From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: fix build error when
	CONFIG_AVERAGE is not enabled
Date: Fri, 17 Jan 2014 18:58:50 -0800 (PST)
Message-ID: <20140117.185850.1095687823504908045.davem@davemloft.net>
References: <1389950828-24039-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com
To: mwdalton@google.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389950828-24039-1-git-send-email-mwdalton@google.com>
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

From: Michael Dalton <mwdalton@google.com>
Date: Fri, 17 Jan 2014 01:27:08 -0800

> Commit ab7db91705e9 ("virtio-net: auto-tune mergeable rx buffer size for
> improved performance") introduced a virtio-net dependency on EWMA.
> The inclusion of EWMA is controlled by CONFIG_AVERAGE. Fix build error
> when CONFIG_AVERAGE is not enabled by adding select AVERAGE to
> virtio-net's Kconfig entry.
> 
> Build failure reported using config make ARCH=s390 defconfig.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Applied.

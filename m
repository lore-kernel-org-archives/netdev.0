From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use kmemdup instead of kmalloc and memcpy
Date: Tue, 27 Dec 2016 20:16:47 -0500 (EST)
Message-ID: <20161227.201647.338740723131819171.davem@davemloft.net>
References: <1482520498-28259-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com
To: mayhs11saini@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482520498-28259-1-git-send-email-mayhs11saini@gmail.com>
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

From: Shyam Saini <mayhs11saini@gmail.com>
Date: Sat, 24 Dec 2016 00:44:58 +0530

> when some other buffer is immediately copied into allocated region.
> Replace calls to kmalloc followed by a memcpy with a direct
> call to kmemdup.
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>

Applied.

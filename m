From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: make array guest_offloads static
Date: Sun, 13 Aug 2017 20:10:08 -0700 (PDT)
Message-ID: <20170813.201008.318311086414456095.davem@davemloft.net>
References: <20170812214553.6073-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: colin.king@canonical.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170812214553.6073-1-colin.king@canonical.com>
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

From: Colin King <colin.king@canonical.com>
Date: Sat, 12 Aug 2017 22:45:53 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The array guest_offloads is local to the source and does not need to
> be in global scope, so make it static. Also tweak formatting.
> 
> Cleans up sparse warnings:
> symbol 'guest_offloads' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [15/16] hostap: convert hostap_cmd_queue.usecnt from atomic_t to
 refcount_t
Date: Mon, 22 May 2017 15:24:55 +0000 (UTC)
Message-ID: <20170522152456.17EC860B7D@smtp.codeaurora.org>
References: <1490691403-4016-16-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, peterz@infradead.org, matanb@mellanox.com,
 paulus@samba.org, Elena Reshetova <elena.reshetova@intel.com>, nbd@openwrt.org,
 linux-rdma@vger.kernel.org, saeedm@mellanox.com, ganeshgr@chelsio.com,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 keescook@chromium.org, j@w1.fi, ajk@comnets.uni-bremen.de, leonro@mellanox.com,
 matthias.bgg@gmail.com, linux-hams@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, blogic@openwrt.org,
 netdev@vger.kernel.org, yishaih@mellanox.com, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-ppp@vger.kernel.org
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1490691403-4016-16-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Elena Reshetova <elena.reshetova@intel.com> wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>

2 patches applied to wireless-drivers-next.git, thanks.

552aa585faff hostap: convert hostap_cmd_queue.usecnt from atomic_t to refcount_t
0aeffa7041d8 orinoco_usb: convert request_context.refcount from atomic_t to refcount_t

-- 
https://patchwork.kernel.org/patch/9648427/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 7/7] uapi: export all headers under uapi directories
Date: Mon, 9 Jan 2017 04:56:38 -0800
Message-ID: <20170109125638.GA15506@infradead.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org,
 linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org,
 linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
 linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 linux-xtensa@linux-xtensa.org, arnd@arndb.de, linux-kbuild@vger.kernel.org,
 adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org,
 linux-metag@vger.kernel.org, linux-arm
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 10:43:59AM +0100, Nicolas Dichtel wrote:
> Regularly, when a new header is created in include/uapi/, the developer
> forgets to add it in the corresponding Kbuild file. This error is usually
> detected after the release is out.
> 
> In fact, all headers under uapi directories should be exported, thus it's
> useless to have an exhaustive list.
> 
> After this patch, the following files, which were not exported, are now
> exported (with make headers_install_all):

... snip ...

> linux/genwqe/.install
> linux/genwqe/..install.cmd
> linux/cifs/.install
> linux/cifs/..install.cmd

I'm pretty sure these should not be exported!

From: Jeff Epler <jepler@unpythonic.net>
Subject: Re: [PATCH v2 7/7] uapi: export all headers under uapi directories
Date: Thu, 12 Jan 2017 19:04:27 -0600
Message-ID: <20170113010427.GA22650@unpythonic.net>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
 <20170109125638.GA15506@infradead.org>
 <464a1323-4450-e563-ff59-9e6d57b75959@6wind.com>
 <alpine.LSU.2.20.1701121727180.19188@erq.vanv.qr>
 <9d68af8a-a609-d7b1-58a9-f1155313b077@6wind.com>
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
 linux-sh@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
 coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
 linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 linux-xtensa@linux-xtensa.org, arnd@arndb.de, linux-kbuild@vger.kernel.org,
 adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, mmarek@suse.com, linux-metag@v
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <9d68af8a-a609-d7b1-58a9-f1155313b077@6wind.com>
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

On Thu, Jan 12, 2017 at 05:32:09PM +0100, Nicolas Dichtel wrote:
> What I was trying to say is that I export those directories like other are.
> Removing those files is not related to that series.

Perhaps the correct solution is to only copy files matching "*.h" to
reduce the risk of copying files incidentally created by kbuild but
which shouldn't be installed as uapi headers.

jeff

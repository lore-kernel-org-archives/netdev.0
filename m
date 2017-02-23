From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/35] treewide trivial patches converting pr_warning to
 pr_warn
Date: Thu, 23 Feb 2017 09:53:41 -0800
Message-ID: <1487872421.14159.38.camel@perches.com>
References: <cover.1487314666.git.joe@perches.com>
 <CAL_JsqLTaq-QLTqfyDO8EVJYpgeUx1e4J0Fo2NvfFWqVoiVedQ@mail.gmail.com>
 <1487870304.14159.29.camel@perches.com>
 <CACvgo50LUm5VSn_F=Dh8kL5zCPpCQDoCyUEL=Z+=1+6hJpfTaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
 linux-ia64@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 ML nouveau <nouveau@lists.freedesktop.org>,
 Linux-ALSA <alsa-devel@alsa-project.org>,
 dri-devel <dri-devel@lists.freedesktop.org>,
 "open list:VIRTIO GPU DRIVER" <virtualization@lists.linux-foundation.org>,
 "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
 "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
 sparclinux@vger.kernel.org, drbd-dev@lists.linbit.com,
 Rob Herring <robh@kernel.org>, linux-omap <linux-omap@vger.kernel.org>,
 linux-scsi@vger.kernel.org, Richard Weinberger <richard@nod.at>,
 tboot-devel@lists.sourceforge.net,
 amd-gfx mailing list <amd-gfx@lists.freedesktop.org>,
 "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
 sfi-devel@simplefirmware.org,
To: Emil Velikov <emil.l.velikov@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CACvgo50LUm5VSn_F=Dh8kL5zCPpCQDoCyUEL=Z+=1+6hJpfTaw@mail.gmail.com>
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

On Thu, 2017-02-23 at 17:41 +0000, Emil Velikov wrote:
> On 23 February 2017 at 17:18, Joe Perches <joe@perches.com> wrote:
> > On Thu, 2017-02-23 at 09:28 -0600, Rob Herring wrote:
> > > On Fri, Feb 17, 2017 at 1:11 AM, Joe Perches <joe@perches.com> wrote:
> > > > There are ~4300 uses of pr_warn and ~250 uses of the older
> > > > pr_warning in the kernel source tree.
> > > > 
> > > > Make the use of pr_warn consistent across all kernel files.
> > > > 
> > > > This excludes all files in tools/ as there is a separate
> > > > define pr_warning for that directory tree and pr_warn is
> > > > not used in tools/.
> > > > 
> > > > Done with 'sed s/\bpr_warning\b/pr_warn/' and some emacsing.
> > 
> > []
> > > Where's the removal of pr_warning so we don't have more sneak in?
> > 
> > After all of these actually get applied,
> > and maybe a cycle or two later, one would
> > get sent.
> > 
> 
> By which point you'll get a few reincarnation of it. So you'll have to
> do the same exercise again :-(

Maybe to one or two files.  Not a big deal.

> I guess the question is - are you expecting to get the series merged
> all together/via one tree ?

No.  The only person that could do that effectively is Linus.

> If not, your plan is perfectly reasonable.

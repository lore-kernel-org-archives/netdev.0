From: Emil Velikov <emil.l.velikov@gmail.com>
Subject: Re: [PATCH 00/35] treewide trivial patches converting pr_warning to
	pr_warn
Date: Thu, 23 Feb 2017 17:41:20 +0000
Message-ID: <CACvgo50LUm5VSn_F=Dh8kL5zCPpCQDoCyUEL=Z+=1+6hJpfTaw@mail.gmail.com>
References: <cover.1487314666.git.joe@perches.com>
	<CAL_JsqLTaq-QLTqfyDO8EVJYpgeUx1e4J0Fo2NvfFWqVoiVedQ@mail.gmail.com>
	<1487870304.14159.29.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	linux-ia64@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	ML nouveau <nouveau@lists.freedesktop.org>,
	Linux-ALSA <alsa-devel@alsa-project.org>,
	dri-devel <dri-devel@lists.freedesktop.org>, "open list:VIRTIO GPU DRIVER"
	<virtualization@lists.linux-foundation.org>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
	sparclinux@vger.kernel.org, drbd-dev@lists.linbit.com,
	Rob Herring <robh@kernel.org>, linux-omap <linux-omap@vger.kernel.org>,
	linux-scsi@vger.kernel.org, Richard Weinberger <richard@nod.at>,
	tboot-devel@lists.sourceforge.net,
	amd-gfx mailing list <amd-gfx@lists.freedesktop.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	sfi-devel@simplefirmware.org,
To: Joe Perches <joe@perches.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1487870304.14159.29.camel@perches.com>
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

On 23 February 2017 at 17:18, Joe Perches <joe@perches.com> wrote:
> On Thu, 2017-02-23 at 09:28 -0600, Rob Herring wrote:
>> On Fri, Feb 17, 2017 at 1:11 AM, Joe Perches <joe@perches.com> wrote:
>> > There are ~4300 uses of pr_warn and ~250 uses of the older
>> > pr_warning in the kernel source tree.
>> >
>> > Make the use of pr_warn consistent across all kernel files.
>> >
>> > This excludes all files in tools/ as there is a separate
>> > define pr_warning for that directory tree and pr_warn is
>> > not used in tools/.
>> >
>> > Done with 'sed s/\bpr_warning\b/pr_warn/' and some emacsing.
> []
>> Where's the removal of pr_warning so we don't have more sneak in?
>
> After all of these actually get applied,
> and maybe a cycle or two later, one would
> get sent.
>
By which point you'll get a few reincarnation of it. So you'll have to
do the same exercise again :-(

I guess the question is - are you expecting to get the series merged
all together/via one tree ? If not, your plan is perfectly reasonable.
Fwiw in the DRM subsystem, similar cleanups does purge the respective
macros/other with the final commit. But there one can pull the lot in
one go.

Regards,
Emil

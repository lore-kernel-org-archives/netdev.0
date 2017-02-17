From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 00/35] treewide trivial patches converting pr_warning to
	pr_warn
Date: Fri, 17 Feb 2017 13:37:33 +0100
Message-ID: <CAMuHMdWsG0DboaLqXag53Vejwvc5PPY2k2gy9PSdHWbNEx6nRQ@mail.gmail.com>
References: <cover.1487314666.git.joe@perches.com>
	<CAJZ5v0gNcGtnXpE1n6LSq7ey+UDKx+oQfmTg0_PgFwzB0Dd_5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:FRAMEBUFFER LAYER" <linux-fbdev@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	nouveau@lists.freedesktop.org,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
	<alsa-devel@alsa-project.org>, dri-devel <dri-devel@lists.freedesktop.org>,
	virtualization@lists.linux-foundation.org,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	MTD Maling List <linux-mtd@lists.infradead.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>,
	"open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>,
	Richard Weinberger <richard@nod.at>,
	sfi-devel@simplefirmware.org, amd-gfx@lists.freedesktop.org,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	tboot-devel@lists.sourceforge.net, oprofil
To: "Rafael J. Wysocki" <rafael@kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJZ5v0gNcGtnXpE1n6LSq7ey+UDKx+oQfmTg0_PgFwzB0Dd_5A@mail.gmail.com>
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

Hi Rafael,

On Fri, Feb 17, 2017 at 1:27 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
> On Fri, Feb 17, 2017 at 8:11 AM, Joe Perches <joe@perches.com> wrote:
>> There are ~4300 uses of pr_warn and ~250 uses of the older
>> pr_warning in the kernel source tree.
>>
>> Make the use of pr_warn consistent across all kernel files.
>>
>> This excludes all files in tools/ as there is a separate
>> define pr_warning for that directory tree and pr_warn is
>> not used in tools/.
>>
>> Done with 'sed s/\bpr_warning\b/pr_warn/' and some emacsing.
>
> Sorry about asking if that has been asked already.
>
> Wouldn't it be slightly less intrusive to simply redefined
> pr_warning() as a synonym for pr_warn()?

That's already the case.

This series cleans up the cruft, so we can catch all users with
"git grep -w pr_warn".

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

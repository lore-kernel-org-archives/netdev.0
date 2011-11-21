From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 14:22:33 -0800
Message-ID: <CA+55aFyy19VYSdZW0+jNxAb8ix0xpX2j9YFw9oQi3jm3+mDEvw@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <201111212249.31196.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Subject =A0 =A0: [3.1-rc8 REGRESSION] sky2 hangs machine on turning off o=
r suspending
> Submitter =A0: Rafa=B3 Mi=B3ecki <zajec5@gmail.com>
> Date =A0 =A0 =A0 : 2011-11-09 11:46
> Message-ID : CACna6ryTdLcWVYgHu=3D_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail.g=
mail.com
> References : http://marc.info/?l=3Dlinux-netdev&m=3D132083922228088&w=3D4

This should be fixed by commit 1401a8008a09 ("sky2: fix hang on
shutdown (and other irq issues)") in current -git.

                   Linus

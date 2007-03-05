From: Mark Lord <lkml@rtr.ca>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Sun, 04 Mar 2007 23:01:33 -0500
Message-ID: <45EB961D.6030808@rtr.ca>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
	<20070305015031.GF3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, Pavel Machek <pavel@ucw.cz>,
   Jeff Garzik <jeff@garzik.org>, Marcel Holtmann <marcel@holtmann.org>,
   linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Sid Boyce <g3vbv@blueyonder.co.uk>, netdev@vger.kernel.org,
   bluez-devel@lists.sourceforge.net, maxk@qualcomm.com,
   Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>,
   Linus Torvalds <torvalds@linux-foundation.org>,
   Johannes Berg <johannes@sipsolutions.net>,
   Albert Hopkins <kernel@marduk.letterboxes.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070305015031.GF3441@stusta.de>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
>
> Subject    : Bluetooth RFComm locks up the machine  (device_move() relate=
d)
> References : http://lkml.org/lkml/2007/3/4/64
> Submitter  : Mark Lord <lkml@rtr.ca>
> Caused-By  : Marcel Holtmann <marcel@holtmann.org>
>              commit c1a3313698895d8ad4760f98642007bf236af2e8
> Status     : unknown

A 2-line patch exists for fs/sysfs/dir.c to address this.
Waiting on Greg to apply it or substitute something prettier.  ;)

Cheers

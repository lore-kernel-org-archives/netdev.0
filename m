From: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Subject: 2.6.20-rc5: known regressions with patches (v2)
Date: Thu, 18 Jan 2007 20:59:15 +0100
Message-ID: <20070118195915.GC9093@stusta.de>
References: <Pine.LNX.4.64.0701121424520.11200@woody.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Michael Gernoth <gernoth-jNDFPZUTrfT6U6xlzOR6HsSSVFg4/55HhC4ANOJQIlc@public.gmane.org>,
	Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-usb-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cpufreq-cunTk1MwBs8iFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David L Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, jffs-dev-VrBV9hrLPhE@public.gmane.org,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701121424520.11200-AgDkxUvNf0y7TbgM5vRIOg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.20-rc5 compared to 2.6.19
with patches available

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possibly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : does not pickup ipv6 addresses
References : http://bugzilla.kernel.org/show_bug.cgi?id=7817
             http://lkml.org/lkml/2007/1/14/146
Submitter  : Michael Gernoth <gernoth-jNDFPZUTrfT6U6xlzOR6HsSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
             Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Caused-By  : David L Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
             commit 30c4cf577fb5b68c16e5750d6bdbd7072e42b279
Handled-By : YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=7817
Status     : patch available


Subject    : ACPI: fix cpufreq regression
References : http://lkml.org/lkml/2007/1/16/120
Submitter  : Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Caused-By  : Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
             commit 0916bd3ebb7cefdd0f432e8491abe24f4b5a101e
Handled-By : Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/1/16/120
Status     : patch available


Subject    : CONFIG_JFFS2_FS_DEBUG=2 compile error
References : http://lkml.org/lkml/2007/1/12/161
Submitter  : Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Caused-By  : Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
             commit 914e26379decf1fd984b22e51fd2e4209b7a7f1b
Handled-By : David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Status     : patch available


Subject    : WARNING: "profile_hits" [drivers/kvm/kvm-intel.ko] undefined!
References : http://lkml.org/lkml/2007/1/12/16
Submitter  : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Caused-By  : Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
             commit 07031e14c1127fc7e1a5b98dfcc59f434e025104
Handled-By : Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/1/12/18
Status     : patch available


Subject    : KVM: guest crash
References : http://lkml.org/lkml/2007/1/8/163
Submitter  : Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Handled-By : Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/1/9/280
Status     : patch available


Subject    : compile error: USB_HID must depend on INPUT
References : http://lkml.org/lkml/2007/1/12/157
Submitter  : Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Handled-By : Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Patch      : http://lkml.org/lkml/2007/1/12/177
Status     : patch available

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

From: Chris Jones <chris.jones@canonical.com>
Subject: e1000e corruption timeline and logs - ubuntu
Date: Fri, 26 Sep 2008 02:21:07 +0100
Message-ID: <48DC3903.5060207@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: jkosina@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tim.gardner@canonical.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:60392 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbYIZBVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 21:21:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

(Apologies for replying in a new thread and crossposting, I'm not
subscribed to these lists and maybe this will make for useful reading.
Also please CC me in replies)

wrt Jiri Kosina's post: alpine.LNX.1.10.0809260042380.3389 () pegasus !
suse ! cz - I hit this bug at the end of August after upgrading to
Ubuntu Intrepid (which was alpha at the time).

Perhaps my timeline[0] would help provide some information to rule
potential culprits out or in by way of Ubuntu's code at the time.
Also I have some logs[2-5] that cover the period surrounding the
corruption happening.

The timeline shows a <24 hour window from my upgrading to Ubuntu
Intrepid (and thus getting a 2.6.27 kernel), and the damage actually
happening.

In conjunction with pages like
https://launchpad.net/ubuntu/+source/linux and
https://launchpad.net/ubuntu/+source/xserver-xorg-video-intel it should
be possible to figure out exactly what source I had in use.

My reading of those pages suggests I had this .config[1]
(which makes sense, it's the oldest 2.6.27 one I have installed and
there doesn't seem to have been a subsequent publishing of an Ubuntu
kernel within the failure window). It also suggests I had
xserver-xorg-video-intel version2:2.4.1-1ubuntu1 (I would not
necessarily trust the version number cf the vanilla intel driver -
tracking down the source package in Launchpad or via #ubuntu-x on
freenode would show exactly which patches were applied). Similarly,
libgl1-mesa-dri 7.1-1ubuntu1.

Apart from (obviously) any occurances where they failed to be written to
disk, I have kern.log[2] and messages[3] for the period (although not
syslog itself, that gets rotated out too quickly, unfortunately, but I
expect kern.log will have any interesting stuff there is to be found).
The mail in [0] references a kernel WARNING bug on Launchpad which ought
to be in kern.log, but just in case it isn't, that bug has it attached.

I also have logs[4][5] which show all package activity before and after
the point of failure, should you be curious about any other versions.

Finally I have some lspci info[6] for the chip from before the error.

Please let me know if there is anything else I can try and pull off my
(now post-RMA) laptop (Thinkpad X300) which may help.

[0] http://mairukipa.tenshu.net/e1000e/timeline.txt
[1] http://mairukipa.tenshu.net/e1000e/config-2.6.27-1-generic
[2] http://mairukipa.tenshu.net/e1000e/kern.log.2.gz
[3] http://mairukipa.tenshu.net/e1000e/messages.2.gz
[4] http://mairukipa.tenshu.net/e1000e/dpkg.log-2008-08-28
[5] http://mairukipa.tenshu.net/e1000e/dpkg.log-2008-08-29
[6] http://mairukipa.tenshu.net/e1000e/lspci.txt

Cheers,
-- 
Chris Jones
  cmsj@canonical.com
   www.canonical.com

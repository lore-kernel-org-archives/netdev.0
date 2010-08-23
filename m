From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 0/1] introduce a syscall for posix clock tuning
Date: Mon, 23 Aug 2010 10:15:57 +0200
Message-ID: <cover.1282550649.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41352 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab0HWIPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 04:15:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently on lkml, we discussed adding a new syscall, with the
motivation of supporting PTP clocks. Here is my suggestion how this
should look like. I would like to get some agreement about this new
interface before proceeding with the PTP stuff itself.

Thanks,
Richard

Richard Cochran (1):
  posix clocks: introduce syscall for clock tuning.

 arch/arm/include/asm/unistd.h      |    1 +
 arch/arm/kernel/calls.S            |    1 +
 arch/blackfin/include/asm/unistd.h |    3 +-
 arch/blackfin/mach-common/entry.S  |    1 +
 arch/powerpc/include/asm/systbl.h  |    1 +
 arch/powerpc/include/asm/unistd.h  |    3 +-
 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/include/asm/unistd_32.h   |    3 +-
 arch/x86/include/asm/unistd_64.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 include/linux/posix-timers.h       |    5 ++++
 include/linux/syscalls.h           |    3 ++
 kernel/compat.c                    |   20 ++++++++++++++++++
 kernel/posix-cpu-timers.c          |    5 ++++
 kernel/posix-timers.c              |   38 ++++++++++++++++++++++++++++++++++++
 15 files changed, 85 insertions(+), 3 deletions(-)


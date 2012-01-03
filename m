From: Daniel Halperin <dhalperi@cs.washington.edu>
Subject: skge warning
Date: Mon, 2 Jan 2012 16:01:55 -0800
Message-ID: <CALSq=BbszVSG1y1doetJjM3BO+0XmWk1UyNqv5XViAUdV+xV6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61658 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2ACACU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 19:02:20 -0500
Received: by vbbfc26 with SMTP id fc26so12211260vbb.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 16:02:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using Linus' current branch.

drivers/net/ethernet/marvell/skge.c:4046: warning: =91skge_suspend=92
defined but not used
drivers/net/ethernet/marvell/skge.c:4071: warning: =91skge_resume=92
defined but not used

It appears to be the use of the wrong CONFIG option. (The code
curently uses CONFIG_PM to see whether these functions are used).
Here's the relevant section of my .config:

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM_RUNTIME=3Dy
CONFIG_PM=3Dy
CONFIG_PM_DEBUG=3Dy
# CONFIG_PM_ADVANCED_DEBUG is not set

Thanks,
Dan

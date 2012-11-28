From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/6] qlcnic: refactor 82xx adapter driver
Date: Wed, 28 Nov 2012 09:34:25 -0500
Message-ID: <1354113271-23850-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50922 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755490Ab2K1OxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 09:53:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx adapter driver to create new files for:
Data path routines.
Sysfs interface routines.
Hardware register dump utility.

We are refactoring the driver code to add support for a new adapter.
Existing 82xx driver code has coding style issues.
Each physical refactoring patch is followed by a seperate patch
to fix the style issues in the newly created file.

Patches in the series are listed below.
0001-qlcnic-create-file-qlcnic_io.c-for-datapath-routines.patch
0002-qlcnic-fix-coding-style-issues-in-qlcnic_io.c.patch
0003-qlcnic-create-file-qlcnic_sysfs.c-for-sysfs-routines.patch
0004-qlcnic-fix-style-issues-in-qlcnic_sysfs.c-file.patch
0005-qlcnic-create-file-qlcnic_minidump.c-for-dump-utilit.patch
0006-qlcnic-fix-coding-style-issues-in-qlcnic_minidump.c.patch

Please apply to net-next.

Thanks,
Sony

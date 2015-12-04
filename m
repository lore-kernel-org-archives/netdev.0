From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 0/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Fri,  4 Dec 2015 08:43:18 +0100
Message-ID: <1449214999-6741-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

Change since v3
- rework the test logic with ver/err

Change since v2
- Invert a test logic

Change since v1
- Always return error code from kstrtox.

LABBE Corentin (1):
  atm: solos-pci: Replace simple_strtol by kstrtoint

 drivers/atm/solos-pci.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

-- 
2.4.10

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 0/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Wed,  2 Dec 2015 13:54:48 +0100
Message-ID: <1449060889-20447-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

Change since v1
- Always return error code from kstrtox.

LABBE Corentin (1):
  atm: solos-pci: Replace simple_strtol by kstrtoint

 drivers/atm/solos-pci.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

-- 
2.4.10

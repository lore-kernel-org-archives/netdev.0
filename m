From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: [PATCH 0/2] Remove redundant function
Date: Fri, 12 Dec 2014 13:34:32 +0100
Message-ID: <20141212123432.GA12765@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Guo-Fu Tseng <cooldavid@cooldavid.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tasklet_hi_enable and tasklet_enable are redundant. Since
tasklet_hi_enable is used only 6 times in 1 file, the first
patch changes calls to the function with calls to tasklet_enable.

The second patch removes tasklet_hi_enable definition.

Quentin Lambert (2):
  jme: replace calls to redundant function
  linux/interrupt.h: remove the definition of unused tasklet_hi_enable

 drivers/net/ethernet/jme.c | 12 ++++++------
 include/linux/interrupt.h  |  6 ------
 2 files changed, 6 insertions(+), 12 deletions(-)

-- 
1.9.1

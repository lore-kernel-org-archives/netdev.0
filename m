From: maximilian attems <janitor@sternwelten.at>
Subject: [patch 3/6] sx8 remove duplicate definition msleep(), msecs_to_jiffies()
Date: Sun, 31 Oct 2004 15:44:54 +0100
Message-ID: <20041031144454.GD28667@stro.at>
References: <20040923221303.GB13244@us.ibm.com> <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <415CD9D9.2000607@pobox.com> <20041030222228.GB1456@stro.at> <41841886.2080609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Margit Schubert-While <margitsw@t-online.de>,
        Nishanth Aravamudan <nacc@us.ibm.com>, hvr@gnu.org,
        mcgrof@studorgs.rutgers.edu, kernel-janitors@lists.osdl.org,
        netdev@oss.sgi.com, Domen Puncer <domen@coderock.org>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41841886.2080609@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




remove duplicate definition msleep(), msecs_to_jiffies().
delay.h already included.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.4.28-rc1-max/drivers/block/sx8.c |   11 -----------
 1 files changed, 11 deletions(-)

diff -puN drivers/block/sx8.c~remove-msleep+msecs_to_jiffies-drivers_block_sx8 drivers/block/sx8.c
--- linux-2.4.28-rc1/drivers/block/sx8.c~remove-msleep+msecs_to_jiffies-drivers_block_sx8	2004-10-31 13:37:56.000000000 +0100
+++ linux-2.4.28-rc1-max/drivers/block/sx8.c	2004-10-31 13:38:56.000000000 +0100
@@ -548,17 +548,6 @@ static int carm_bdev_ioctl(struct inode 
 	return -EOPNOTSUPP;
 }
 
-static inline unsigned long msecs_to_jiffies(unsigned long msecs)
-{
-	return ((HZ * msecs + 999) / 1000);
-}
-
-static void msleep(unsigned long msecs)
-{
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(msecs) + 1);
-}
-
 static const u32 msg_sizes[] = { 32, 64, 128, CARM_MSG_SIZE };
 
 static inline int carm_lookup_bucket(u32 msg_size)
_

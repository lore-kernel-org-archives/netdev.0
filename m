From: maximilian attems <janitor@sternwelten.at>
Subject: [patch 2/6] libata remove duplicate definition msecs_to_jiffies()
Date: Sun, 31 Oct 2004 15:44:42 +0100
Message-ID: <20041031144442.GC28667@stro.at>
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



remove duplicate definition of msecs_to_jiffies().
already includes delay.h

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.4.28-rc1-max/include/linux/libata.h |    5 -----
 1 files changed, 5 deletions(-)

diff -puN include/linux/libata.h~remove-msecs_to_jiffies-libata.h include/linux/libata.h
--- linux-2.4.28-rc1/include/linux/libata.h~remove-msecs_to_jiffies-libata.h	2004-10-31 13:33:52.000000000 +0100
+++ linux-2.4.28-rc1-max/include/linux/libata.h	2004-10-31 13:36:16.000000000 +0100
@@ -419,11 +419,6 @@ extern int ata_std_bios_param(Disk * dis
 extern void libata_msleep(unsigned long msecs);
 
 
-static inline unsigned long msecs_to_jiffies(unsigned long msecs)
-{
-	return ((HZ * msecs + 999) / 1000);
-}
-
 static inline unsigned int ata_tag_valid(unsigned int tag)
 {
 	return (tag < ATA_MAX_QUEUE) ? 1 : 0;
_

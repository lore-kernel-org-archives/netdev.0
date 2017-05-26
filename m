From: David Daney <david.daney@cavium.com>
Subject: [PATCH 2/5] MIPS: Correctly define DBSHFL type instruction opcodes.
Date: Thu, 25 May 2017 17:38:23 -0700
Message-ID: <20170526003826.10834-3-david.daney@cavium.com>
References: <20170526003826.10834-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170526003826.10834-1-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

DSHD was incorrectly classified as being BSHFL, and DSHD was missing
altogether.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/include/uapi/asm/inst.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/mips/include/uapi/asm/inst.h b/arch/mips/include/uapi/asm/inst.h
index b5e46ae..e5f5385 100644
--- a/arch/mips/include/uapi/asm/inst.h
+++ b/arch/mips/include/uapi/asm/inst.h
@@ -276,12 +276,19 @@ enum lx_func {
  */
 enum bshfl_func {
 	wsbh_op = 0x2,
-	dshd_op = 0x5,
 	seb_op  = 0x10,
 	seh_op  = 0x18,
 };
 
 /*
+ * DBSHFL opcodes
+ */
+enum dbshfl_func {
+	dsbh_op = 0x2,
+	dshd_op = 0x5,
+};
+
+/*
  * MSA minor opcodes.
  */
 enum msa_func {
-- 
2.9.4

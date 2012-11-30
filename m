From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 09:28:19 -0800
Message-ID: <50B8ECB3.2090801@schaufler-ca.com>
References: <20121129174057.99da02b15426c76054d05592@canb.auug.org.au> <50B7F846.70202@infradead.org> <3694027.VYznNcdp7C@sifl> <2664553.2TRaVqlkGg@sifl> <50B8E4E6.2040901@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul@paul-moore.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-security-module@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50B8E4E6.2040901@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because NETLABEL depends on INET SECURITY_SMACK
has to explicitly call out the dependency.

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
---
 security/smack/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/security/smack/Kconfig b/security/smack/Kconfig
index 9fb14ef..1be1088 100644
--- a/security/smack/Kconfig
+++ b/security/smack/Kconfig
@@ -1,5 +1,6 @@
 config SECURITY_SMACK
 	bool "Simplified Mandatory Access Control Kernel Support"
+	depends on INET
 	depends on NET
 	depends on SECURITY
 	select NETLABEL

From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: kconfig (1/8)
Date: Fri, 31 Jan 2003 09:46:56 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301310942430.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301310916040.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301310916040.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+)


diff -urN -X dontdiff linux-2.5.59.w0/security/Kconfig linux-2.5.59.w1/security/Kconfig
--- linux-2.5.59.w0/security/Kconfig	Tue Dec 24 23:31:09 2002
+++ linux-2.5.59.w1/security/Kconfig	Thu Jan 30 21:18:42 2003
@@ -15,6 +15,15 @@
 
 	  If you are unsure how to answer this question, answer N.
 
+config SECURITY_NETWORK
+	bool "Socket and Networking Security Hooks"
+	depends on SECURITY
+	help
+	  This enables the socket and networking security hooks.
+	  If enabled, a security module can use these hooks to
+	  implement socket and networking access controls.
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY_CAPABILITIES
 	tristate "Default Linux Capabilities"
 	depends on SECURITY!=n

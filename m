From: domen@coderock.org
Subject: [patch 2/2] delete unused file
Date: Sun, 26 Dec 2004 16:12:15 +0100
Message-ID: <20041226151159.393C91F125@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Remove nowhere referenced file. (egrep "filename\." didn't find anything)

Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj/net/sunrpc/auth_gss/sunrpcgss_syms.c |   37 --------------------------------
 1 files changed, 37 deletions(-)

diff -L net/sunrpc/auth_gss/sunrpcgss_syms.c -puN net/sunrpc/auth_gss/sunrpcgss_syms.c~remove_file-net_sunrpc_auth_gss_sunrpcgss_syms.c /dev/null
--- kj/net/sunrpc/auth_gss/sunrpcgss_syms.c
+++ /dev/null	2004-12-24 01:21:08.000000000 +0100
@@ -1,37 +0,0 @@
-#include <linux/config.h>
-#include <linux/module.h>
-
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/sched.h>
-#include <linux/uio.h>
-#include <linux/unistd.h>
-
-#include <linux/sunrpc/auth_gss.h>
-#include <linux/sunrpc/svcauth_gss.h>
-#include <linux/sunrpc/gss_asn1.h>
-#include <linux/sunrpc/gss_krb5.h>
-
-/* svcauth_gss.c: */
-EXPORT_SYMBOL(svcauth_gss_register_pseudoflavor);
-
-/* registering gss mechanisms to the mech switching code: */
-EXPORT_SYMBOL(gss_mech_register);
-EXPORT_SYMBOL(gss_mech_unregister);
-EXPORT_SYMBOL(gss_mech_get);
-EXPORT_SYMBOL(gss_mech_get_by_pseudoflavor);
-EXPORT_SYMBOL(gss_mech_get_by_name);
-EXPORT_SYMBOL(gss_mech_put);
-EXPORT_SYMBOL(gss_pseudoflavor_to_service);
-EXPORT_SYMBOL(gss_service_to_auth_domain_name);
-
-/* generic functionality in gss code: */
-EXPORT_SYMBOL(g_make_token_header);
-EXPORT_SYMBOL(g_verify_token_header);
-EXPORT_SYMBOL(g_token_size);
-EXPORT_SYMBOL(make_checksum);
-EXPORT_SYMBOL(krb5_encrypt);
-EXPORT_SYMBOL(krb5_decrypt);
-
-/* debug */
-EXPORT_SYMBOL(print_hexl);
_

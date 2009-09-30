From: Hannes Eder <heder@google.com>
Subject: [PATCH] conntrack: do not print garbage after the usage message
Date: Wed, 30 Sep 2009 15:02:09 +0200
Message-ID: <20090930130142.16484.76529.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Cc: netfilter-devel@vger.kernel.org
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When 'conntrack' is called with no arguments then garbage is printed
after the usage message.  This patch fixes this.

Signed-off-by: Hannes Eder <heder@google.com>

 src/conntrack.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/conntrack.c b/src/conntrack.c
index 42b5133..5ca68d1 100644
--- a/src/conntrack.c
+++ b/src/conntrack.c
@@ -1493,7 +1493,7 @@ int main(int argc, char *argv[])
 
 	free_options();
 
-	if (exit_msg[cmd][0]) {
+	if (cmd != CT_NONE && exit_msg[cmd][0]) {
 		fprintf(stderr, "%s v%s (conntrack-tools): ",PROGNAME,VERSION);
 		fprintf(stderr, exit_msg[cmd], counter);
 		if (counter == 0 && !(command & (CT_LIST | EXP_LIST)))


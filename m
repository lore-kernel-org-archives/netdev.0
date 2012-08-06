From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Mon, 06 Aug 2012 16:39:05 -0700
Message-ID: <1344296345.2026.3.camel@joe2Laptop>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	 <1344263012-4031-8-git-send-email-amwang@redhat.com>
	 <20120806.135003.442648448779232464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36526 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755636Ab2HFXjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 19:39:07 -0400
In-Reply-To: <20120806.135003.442648448779232464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 13:50 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Mon,  6 Aug 2012 22:23:31 +0800
> 
> > +	/*
> > +	 * We don't notify NETDEV_RELEASE event, as this will
> > +	 * stop netconsole on the bridge.
> > +	 */
> 
> Please format comments in the networking:
> 
> 	/* Like
> 	 * this.
> 	 */

Maybe add a networking specific block comment style
to checkpatch. This doesn't trigger on files outside
of drivers/net and net.

---

 scripts/checkpatch.pl |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 913d6bd..560f012 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1873,6 +1873,13 @@ sub process {
 			    "No space is necessary after a cast\n" . $hereprev);
 		}
 
+		if ($realfile =~ m@^(drivers/net/|net/)@ &&
+		    $rawline =~ /^\+[ \t]*\/\*[ \t]*$/ &&
+		    $prevrawline =~ /^\+[ \t]*$/) {
+			WARN("NETWORKING_BLOCK_COMMENT_STYLE",
+			     "networking block comments don't use an empty /* line, use /* Comment...\n" . $hereprev);
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments

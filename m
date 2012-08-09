From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH] SubmittingPatches: clarify SOB tag usage when evolving submissions
Date: Thu,  9 Aug 2012 13:51:33 -0700
Message-ID: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Cc: rdunlap@xenotime.net, tytso@mit.edu, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>

Initial large code submissions typically are not accepted
on their first patch submission. The developers are
typically given feedback and at times some developers may
even submit changes to the original authors for integration
into their second submission attempt.

Developers wishing to contribute changes to the evolution
of a second patch submission must supply their own Siged-off-by
tag to the original authors and must submit their changes
on a public mailing list or ensure that these submission
are recorded somewhere publicly.

To date a few of these type of contributors have expressed
different preferences for whether or not their own SOB tag
should be used for a second code submission. Lets keep things
simple and only require the contributor's SOB tag if so desired
explicitly. It is not technically required if there already
is a public record of their contribution somewhere.

Document this on Documentation/SubmittingPatches

Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>
---
 Documentation/SubmittingPatches |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
index c379a2a..e018043 100644
--- a/Documentation/SubmittingPatches
+++ b/Documentation/SubmittingPatches
@@ -366,6 +366,21 @@ and protect the submitter from complaints. Note that under no circumstances
 can you change the author's identity (the From header), as it is the one
 which appears in the changelog.
 
+If you are submitting a large change (for example a new driver) at times
+you may be asked to make quite a lot of modifications prior to getting
+your change accepted. At times you may even receive patches from developers
+who not only wish to tell you what you should change to get your changes
+upstream but actually send you patches. If those patches were made publicly
+and they do contain a Singed-off-by tag you are not expected to provide
+their own Singed-off-by tag on the second iteration of the patch so long
+as there is a public record somewhere that can be used to show the
+contributor had sent their changes with their own Singed-off-by tag.
+
+If you receive patches privately during development you may want to
+ask for these patches to be re-posted publicly or you can also decide
+to merge the patches as part of a separate historical git tree that
+will remain online for historical archiving.
+
 Special note to back-porters: It seems to be a common and useful practise
 to insert an indication of the origin of a patch at the top of the commit
 message (just after the subject line) to facilitate tracking. For instance,
-- 
1.7.10.4

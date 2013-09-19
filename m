From: Joe Perches <joe@perches.com>
Subject: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Thu, 19 Sep 2013 11:31:14 -0700
Message-ID: <1379615474.22168.13.camel@joe-AO722>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
	 <20130919.135628.1201613770803318193.davem@davemloft.net>
	 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking is once again "special", so at least document
how it's working today in the hope that doing so makes
less work for all that actually read the documentation.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 19 Sep 2013, David Miller wrote:
> Secondly, CC:'ing stable is not the correct way to submit networking
> patches for -stable inclusion.  You simply ask me to queue them up
> for -stable explicitly instead.

 Documentation/stable_kernel_rules.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
index b0714d8..a2d6da0 100644
--- a/Documentation/stable_kernel_rules.txt
+++ b/Documentation/stable_kernel_rules.txt
@@ -29,6 +29,11 @@ Rules on what kind of patches are accepted, and which ones are not, into the
 
 Procedure for submitting patches to the -stable tree:
 
+ - The networking tree (net/ and drivers/net/) is 'special' and doesn't
+   follow the rules below.  Don't send or cc: patches for the -stable tree to
+   stable@vger.kernel.org.  Don't mark them stable.  Just send the patches to
+   netdev@vger.kernel.org and let the networking maintainer decide what to do
+   with them.
  - Send the patch, after verifying that it follows the above rules, to
    stable@vger.kernel.org.  You must note the upstream commit ID in the
    changelog of your submission, as well as the kernel version you wish




From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 38/39] wimax: export linux/wimax.h and linux/wimax/i2400m.h with headers_install
Date: Tue, 25 Nov 2008 23:59:38 -0800
Message-ID: <200811252359.38850.inaky@linux.intel.com>
References: <cover.1227684995.git.inaky@linux.intel.com> <ed11bd9071b2dbb8c4d093110724b2e5e8eb9d43.1227684996.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:7588 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751364AbYKZIAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 03:00:13 -0500
In-Reply-To: <ed11bd9071b2dbb8c4d093110724b2e5e8eb9d43.1227684996.git.inaky@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 November 2008, Inaky Perez-Gonzalez wrote:
> These two files are what user space can use to establish communication
> with the WiMAX kernel API and to speak the Intel 2400m Wireless WiMAX
> connection's control protocol.

Oops, sorry, missed including include/linux/wimax/Kbuild here -- here 
is the ammendment:

These two files are what user space can use to establish communication
with the WiMAX kernel API and to speak the Intel 2400m Wireless WiMAX
connection's control protocol.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 include/linux/Kbuild       |    2 ++
 include/linux/wimax/Kbuild |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/wimax/Kbuild

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e531783..89079ff 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -375,3 +375,5 @@ unifdef-y += xattr.h
 unifdef-y += xfrm.h
 
 objhdr-y += version.h
+header-y += wimax.h
+header-y += wimax/
diff --git a/include/linux/wimax/Kbuild b/include/linux/wimax/Kbuild
new file mode 100644
index 0000000..3cb4f26
--- /dev/null
+++ b/include/linux/wimax/Kbuild
@@ -0,0 +1 @@
+header-y += i2400m.h
-- 
1.5.6.5


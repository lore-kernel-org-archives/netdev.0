From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] x86: export set_memory_ro() and set_memory_rw() calls
Date: Tue, 23 Sep 2008 15:28:48 -0700
Message-ID: <20080923222848.6281.23319.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:50256 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbYIWW2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 18:28:43 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2383420rvb.1
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 15:28:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Export set_memory_ro() and set_memory_rw() calls needed by a follow-on
patch to the e1000e driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 arch/x86/mm/pageattr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 43e2f84..0991e15 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -906,11 +906,13 @@ int set_memory_ro(unsigned long addr, int numpages)
 {
 	return change_page_attr_clear(addr, numpages, __pgprot(_PAGE_RW));
 }
+EXPORT_SYMBOL(set_memory_ro);
 
 int set_memory_rw(unsigned long addr, int numpages)
 {
 	return change_page_attr_set(addr, numpages, __pgprot(_PAGE_RW));
 }
+EXPORT_SYMBOL(set_memory_rw);
 
 int set_memory_np(unsigned long addr, int numpages)
 {


From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [PATCH 0/4] atlx: add atl2 support
Date: Tue, 9 Sep 2008 20:49:12 -0500
Message-ID: <20080909204912.7c043f65@osprey.hogchain.net>
References: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net, csnook@redhat.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:41064 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbYIJBti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 21:49:38 -0400
Received: by mail-gx0-f16.google.com with SMTP id 9so12469757gxk.13
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 18:49:37 -0700 (PDT)
In-Reply-To: <20080909061247.GA17834@file.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Sep 2008 02:12:47 -0400
Chris Snook <csnook@redhat.com> wrote:

> This patchset adds support for atl2 hardware to the atlx codebase.
> It is functionally very similar to the out-of-tree 2.0.4 version that
> many distros have been shipping for a few months, though it adds a
> fix from Atheros to fix the problem of device resets under heavy
> bidirectional load.
> 
> The code needs a lot of janitorial work, and there's a lot of
> low-hanging fruit for merging similar atl1 code into the shared atlx
> code, but I think that work will go much faster once this is
> in-tree.  The driver is known to work well for laptop and desktop
> use.  The only major bugs are device initialization problems that
> manifest themselves immediately and obviously (the NIC doesn't work)
> with certain motherboards.
> 
> Please consider this for the 2.6.28 merge window.
> 
> -- Chris
> 
>  drivers/net/Kconfig       |   17
>  drivers/net/Makefile      |    1
>  drivers/net/atlx/Makefile |    1
>  drivers/net/atlx/atl2.c   | 3101
> ++++++++++++++++++++++++++++++++++++++++++++++
> drivers/net/atlx/atl2.h   |  482 +++++++ include/linux/pci_ids.h
> |    1 6 files changed, 3600 insertions(+), 3 deletions(-)

There's a compiler warning.  This patch fixes it.

commit 1deec1774c18a46dbd89bf5ef8a3dc5be270fa2d
Author: Jay Cliburn <jacliburn@bellsouth.net>
Date:   Tue Sep 9 20:38:18 2008 -0500

    atl2: eliminate compiler warning
    
    Eliminate compiler warning.
    
    drivers/net/atlx/atl2.c:2928: warning: useless storage class
    specifier in empty declaration
    
    Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 8ba4a98..c4c98c7 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -2910,7 +2910,7 @@ ATL2_PARAM(FlashVendor, "SPI Flash Vendor");
 #define FLASH_VENDOR_MIN       0
 #define FLASH_VENDOR_MAX       2
 
-static struct atl2_option {
+struct atl2_option {
        enum { enable_option, range_option, list_option } type;
        char *name;
        char *err;


From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 18/23] e1000: revert 'e1000: Remove 0x1000 as supported
 device'
Date: Tue, 19 Sep 2006 13:34:18 -0700
Message-ID: <4510544A.8080809@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172913.4605.84224.stgit@gitlost.site> <451047BF.6070907@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7070 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1752062AbWISUiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:38:05 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451047BF.6070907@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> The commit 'e1000: Remove 0x1000 as supported device' (Jeff Kirsher,
>> 673a052fde79ab5e9dce569b0336358812ddba2d) Removes PIC device ID 8086:1000
>> from the list of supported devices. A fix was submitted for the original
>> issue (commit 6a9516989f94df10d9a27ba543c6b53b3e69c84a).
>>
>> This commit reverts commit 673a052fde79ab5e9dce569b0336358812ddba2d and
>> re-enables 82542rev3 chips completely.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  0 files changed, 0 insertions(+), 0 deletions(-)
> 
> null patch

hmm, it should look like this:


---

e1000: revert 'e1000: Remove 0x1000 as supported device'

The commit 'e1000: Remove 0x1000 as supported device' (Jeff Kirsher,
673a052fde79ab5e9dce569b0336358812ddba2d) Removes PIC device ID 8086:1000
from the list of supported devices. A fix was submitted for the original
issue (commit 6a9516989f94df10d9a27ba543c6b53b3e69c84a).

This commit reverts commit 673a052fde79ab5e9dce569b0336358812ddba2d and
re-enables 82542rev3 chips completely.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1d7c999..a8d724e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -48,6 +48,7 @@ static char e1000_copyright[] = "Copyrig
   *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
   */
  static struct pci_device_id e1000_pci_tbl[] = {
+       INTEL_E1000_ETHERNET_DEVICE(0x1000),
         INTEL_E1000_ETHERNET_DEVICE(0x1001),
         INTEL_E1000_ETHERNET_DEVICE(0x1004),
         INTEL_E1000_ETHERNET_DEVICE(0x1008),

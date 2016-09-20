From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] ixgbe: replace defined with IS_ENABLED
Date: Tue, 20 Sep 2016 21:09:47 +0800
Message-ID: <CAD=hENd2MO-3AuFZQz0i4sPSf5puDyrqgDw8Xgh=LnOXPizVrQ@mail.gmail.com>
References: <1473866814-21374-1-git-send-email-zyjzyj2000@gmail.com>
	<87618083B2453E4A8714035B62D67992506E6E4B@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87618083B2453E4A8714035B62D67992506E6E4B@FMSMSX105.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

how about this patch "ixgbe: remove the useless header file ixgbe_type.h"?

On Tue, Sep 20, 2016 at 1:00 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>Behalf Of zyjzyj2000@gmail.com
>>Sent: Wednesday, September 14, 2016 8:27 AM
>>To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher,
>>Jeffrey T <jeffrey.t.kirsher@intel.com>; zyjzyj2000@gmail.com; e1000-
>>devel@lists.sourceforge.net
>>Subject: [PATCH 1/1] ixgbe: replace defined with IS_ENABLED
>>
>>From: Zhu Yanjun <zyjzyj2000@gmail.com>
>>
>>Replace defined macro with IS_ENABLED in ixgbe.h file
>>
>>Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>>---
>> drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>index 9475ff9..f8bc1d0 100644
>>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>>@@ -45,7 +45,7 @@
>> #include "ixgbe_type.h"
>> #include "ixgbe_common.h"
>> #include "ixgbe_dcb.h"
>>-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>>+#if IS_ENABLED(CONFIG_FCOE)
>> #define IXGBE_FCOE
>> #include "ixgbe_fcoe.h"
>> #endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
>>--
>>2.7.4
>
> Already taken care of by the following patch:
> http://patchwork.ozlabs.org/patch/668894/
>
> Thanks,
> Emil
>

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

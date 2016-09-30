From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] qed: mark symbols static where possible
Date: Fri, 30 Sep 2016 16:29:39 +0200
Message-ID: <201609301629.39922.arnd@arndb.de>
References: <1475222189-19092-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:52474 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932968AbcI3OaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 10:30:04 -0400
In-Reply-To: <1475222189-19092-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 September 2016, Baoyou Xie wrote:
> 
> We get 12 warnings when building kernel with W=1:
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:346:6: warning: no previous prototype for 'qed_cxt_set_srq_count' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:353:5: warning: no previous prototype for 'qed_cxt_get_srq_count' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:389:5: warning: no previous prototype for 'qed_cxt_get_proto_cid_start' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:395:5: warning: no previous prototype for 'qed_cxt_get_proto_tid_count' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_cxt.c:1801:6: warning: no previous prototype for 'qed_rdma_set_pf_params' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:4031:17: warning: no previous prototype for 'qed_mcp_trace_dump' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:4133:17: warning: no previous prototype for 'qed_reg_fifo_dump' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:4195:17: warning: no previous prototype for 'qed_igu_fifo_dump' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:4258:17: warning: no previous prototype for 'qed_protection_override_dump' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:6342:17: warning: no previous prototype for 'qed_print_idle_chk_results_wrapper' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:6416:17: warning: no previous prototype for 'format_feature' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_debug.c:6483:17: warning: no previous prototype for 'qed_dbg_dump' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> So this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Acked-by: Arnd Bergmann <arnd@arndb.de>

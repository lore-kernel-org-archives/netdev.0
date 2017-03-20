From: Stephen Hemminger <stephen@networkplumber.org>
Subject: liquidio: coverity scan errors
Date: Mon, 20 Mar 2017 08:02:21 -0700
Message-ID: <20170320080221.305727fa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34880 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754282AbdCTPLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 11:11:00 -0400
Received: by mail-pg0-f44.google.com with SMTP id t143so12969965pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 08:10:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This showed up new Coverity scan erros
** CID 1403160:    (FORWARD_NULL)
/drivers/net/ethernet/cavium/liquidio/lio_main.c: 802 in setup_glists()
/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c: 560 in setup_glists()


________________________________________________________________________________________________________
*** CID 1403160:    (FORWARD_NULL)
/drivers/net/ethernet/cavium/liquidio/lio_main.c: 802 in setup_glists()
796     	 */
797     	lio->glists_virt_base = kcalloc(num_iqs, sizeof(*lio->glists_virt_base),
798     					GFP_KERNEL);
799     	lio->glists_dma_base = kcalloc(num_iqs, sizeof(*lio->glists_dma_base),
800     				       GFP_KERNEL);
801     
>>>     CID 1403160:    (FORWARD_NULL)
>>>     Comparing "lio->glists_dma_base" to null implies that "lio->glists_dma_base" might be null.  
802     	if (!lio->glists_virt_base || !lio->glists_dma_base) {
803     		delete_glists(lio);
804     		return -ENOMEM;
805     	}
806     
807     	for (i = 0; i < num_iqs; i++) {
/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c: 560 in setup_glists()
554     	 */
555     	lio->glists_virt_base = kcalloc(num_iqs, sizeof(*lio->glists_virt_base),
556     					GFP_KERNEL);
557     	lio->glists_dma_base = kcalloc(num_iqs, sizeof(*lio->glists_dma_base),
558     				       GFP_KERNEL);
559     
>>>     CID 1403160:    (FORWARD_NULL)
>>>     Comparing "lio->glists_dma_base" to null implies that "lio->glists_dma_base" might be null.  
560     	if (!lio->glists_virt_base || !lio->glists_dma_base) {
561     		delete_glists(lio);
562     		return -ENOMEM;
563     	}
564     
565     	for (i = 0; i < num_iqs; i++) {

** CID 1403161:  Memory - illegal accesses  (OVERRUN)

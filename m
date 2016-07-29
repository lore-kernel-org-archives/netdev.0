From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 0/3] bna: remove useless global variables
Date: Fri, 29 Jul 2016 19:52:55 +0200
Message-ID: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217AbcG2RxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 13:53:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set removes useless global bnad_list as well as bnad->entry that track
a list of driver instances but it is not used anywhere. The associated
bnad_list_mutex is removed as well but as it is also used to protect
bna_id increment it is necessary to convert bna_id to atomic_t.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>

 drivers/net/ethernet/brocade/bna/bnad.c | 27 ++-------------------------
 drivers/net/ethernet/brocade/bna/bnad.h |  1 -
 2 files changed, 2 insertions(+), 26 deletions(-)

-- 
2.7.3

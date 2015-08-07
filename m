From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: RE: [PATCH net] bna: fix interrupts storm caused by erroneous
 packets
Date: Fri, 7 Aug 2015 18:35:43 +0000
Message-ID: <2552F74A0BCCBE4DBE2AD218C81B281108518A6A@avmb3.qlogic.org>
References: <1438894103-10597-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ivan Vecera <ivecera@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62646 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946070AbbHGSfr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 14:35:47 -0400
In-Reply-To: <1438894103-10597-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Thursday, August 06, 2015 1:48 PM
> 
> The commit "e29aa33 bna: Enable Multi Buffer RX" moved packets counter
> increment from the beginning of the NAPI processing loop after the check
> for erroneous packets so they are never accounted. This counter is used to
> inform firmware about number of processed completions (packets).
> As these packets are never acked the firmware fires IRQs for them again and
> again.
> 
> Fixes: e29aa33 bna: Enable Multi Buffer RX
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Rasesh Mody <rasesh.mody@qlogic.com>

Thanks!
Rasesh

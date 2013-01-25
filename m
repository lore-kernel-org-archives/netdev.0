From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [patch] qlcnic: silence false positive overflow warning
Date: Fri, 25 Jan 2013 20:48:02 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E05050A@avmb2.qlogic.org>
References: <20130125064141.GB4882@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:25374 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751087Ab3AYUsU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:48:20 -0500
In-Reply-To: <20130125064141.GB4882@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Dan Carpenter [mailto:dan.carpenter@oracle.com] 
>Sent: Thursday, January 24, 2013 10:42 PM
>To: Jitendra Kalsaria
>Cc: Sony Chacko; Dept-Eng Linux Driver; netdev; kernel-janitors@vger.kernel.org
>Subject: [patch] qlcnic: silence false positive overflow warning
>
>We actually store the MAC address as well as the board_name here.  The
>longest board_name is 75 characters so there is more than enough room
>to hold the 17 character MAC and the ": " divider.  But making this
>buffer larger silences a static checker warning.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>---
>I'm not sure if this is worth sending.  Feel free to drop this if you
>want.

Acked-By: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

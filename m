From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 15:45:03 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A991565@alice.at.omicron.at>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
 <20120105.132637.2130515220408371607.davem@davemloft.net>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
 <20120109124908.GB4404@cherladcori01>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:41226 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab2AIOpV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 09:45:21 -0500
In-Reply-To: <20120109124908.GB4404@cherladcori01>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org [mailto:netdev-
owner@vger.kernel.org] On Behalf Of Richard Cochran
Sent: Monday, January 09, 2012 13:49

>Hi Manfred,
>
>You have to make sure the new clone holds a reference on skb->sk.
>A recent, similar problem was discussed:
>
>    http://comments.gmane.org/gmane.linux.network/208143
>
>And the solution came in:
>
>    commit da92b194cc36b5dc1fbd85206aeeffd80bee0c39
>    Author: Richard Cochran <richardcochran@gmail.com>
>    Date:   Fri Oct 21 00:49:15 2011 +0000
>
>    net: hold sock reference while processing tx timestamps

Thanks Richard, I will come up with a new version.

Regard,
Manfred

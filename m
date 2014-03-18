From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] VXLAN: fix potential NULL dereference in arp_reduce()
Date: Tue, 18 Mar 2014 10:57:43 -0600
Message-ID: <OF6DB4D166.F9450AC6-ON87257C9F.005D2CBF-87257C9F.005D2CC2@us.ibm.com>
References: <CAHA+R7O+Njk2vbfEg+RfrRJ=x1JdXTheZQwhu4PpU47Bgk2CHQ@mail.gmail.com>,
	<201403181632.s2IGWTjT003613@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:59887 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbaCRQ5v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:57:51 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 18 Mar 2014 10:57:51 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2A34B19D8041
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:57:46 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2IGvn0s6160702
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 17:57:49 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2IGvlv2023646
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:57:48 -0600
In-Reply-To: <CAHA+R7O+Njk2vbfEg+RfrRJ=x1JdXTheZQwhu4PpU47Bgk2CHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: Cong Wang=20

>
>Nit: move it right after arp_create(). Otherwise:
>

That would exit without releasing the neighbor reference.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+-DLS

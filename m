From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Mon, 10 Jun 2013 07:00:49 -0600
Message-ID: <OF7613FEAD.8B74A56A-ON87257B86.00477CA0-87257B86.00477CA3@us.ibm.com>
References: <1370833744.11543.4.camel@cr0>,
	<1370689003.868.3.camel@cr0>	 , <1370485211-11498-1-git-send-email-amwang@redhat.com>
	 <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>	 <OF76532841.5DDD0996-ON87257B85.000C25DF-87257B85.000C25E6@us.ibm.com>
	 <1370833653.11543.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev-owner@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52701 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab3FJNCz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 09:02:55 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 10 Jun 2013 07:02:54 -0600
In-Reply-To: <1370833744.11543.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>On Mon, 2013-06-10 at 11:07 +0800, Cong Wang wrote: >  > Are you
>suggesting to just make ip_mc_leave_src() void?  I meant
>ip_mc_del_src() of course...

Yes. At least, unless you find text in the API standard that says
this case should return an error.

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 +-DLS

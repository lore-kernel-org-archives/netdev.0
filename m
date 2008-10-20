From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Mon, 20 Oct 2008 09:38:39 +0000
Message-ID: <20081020093839.GA6203@ff.dom.local>
References: <20081018215007.GB6048@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/SWxwb19KPUU0cnZpbmVuPz0=?=
	<ilpo.jarvinen@helsinki.fi>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50671 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbYJTJis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:38:48 -0400
Received: by ug-out-1314.google.com with SMTP id k3so631358ugf.37
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 02:38:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081018215007.GB6048@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Sat, Oct 18, 2008 at 01:20:56PM -0700, bugme-daemon@bugzilla.kernel.org wrote:
>>> http://bugzilla.kernel.org/show_bug.cgi?id=11721
...
>>> ------- Comment #30 from sentiniate@tiscali.it  2008-10-18 13:20 -------
...
>>> afterwards i've run some more tests and have found out that the culprit is
>>> tcp_sack, if using kernel 2.6.27-rc1-gt1 it is set to "1" i cannot navigate if
>>> to "0" i can.
...

Aldo, for curiosity, could you also try if this change only
(instead of tcp_sack etc.) can't do similar effect?:

echo 0 > /proc/sys/net/ipv4/tcp_timestamps

Thanks,
Jarek P.

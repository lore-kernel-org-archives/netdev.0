From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Mon, 6 Apr 2015 22:44:06 +0200
Message-ID: <20150406204406.GA27153@electric-eye.fr.zoreil.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <CAEP_g=9PbDO4qK-GaGosBAq1S5C5uWNR4-JN8=i158oYJUN4Bw@mail.gmail.com>
 <20150404010142.GA1063@electric-eye.fr.zoreil.com>
 <CAEP_g=-qyy6PNEqKQWVaw5Wf9MvcUk-Hx5Mrk7jaTEihK3Tqzg@mail.gmail.com>
 <20150406184409.GC2866@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50617 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbbDFUoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:44:55 -0400
Content-Disposition: inline
In-Reply-To: <20150406184409.GC2866@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John W. Linville <linville@tuxdriver.com> :
[...]
> What would you suggest, Francois?  A GENEVE_CRIT_OPT_PRESENT() macro?

Either that or a typed 'bool geneve_crit_opt_present(struct geneve_opt *opt)'
to hide the content of struct geneve_opt and move any relevant bitmask in
the only .c file where it is actually used.

-- 
Ueimor

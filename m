From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: Query about skb scatter / gather
Date: Mon, 9 Mar 2009 16:02:04 +0200
Message-ID: <200903091602.05102.remi.denis-courmont@nokia.com>
References: <c8028d330903060917r4af01c7ew2426bcb30af90b5e@mail.gmail.com>  <F169D4F5E1F1974DBFAFABF47F60C10A1E6EB189@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amar Mudrankit <amar.mudrankit@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "ext Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:38913 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbZCIOCI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 10:02:08 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1E6EB189@orsmsx507.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 March 2009 21:47:22 ext Brandeburg, Jesse wrote:
> frag_list can only be safely used in rare cases where you know that
> the ip defragmentation code will not be called.  It links multiple
> skb's together to form one large packet (for receive)

Uh? Sure, nested fragments do not work.
But... My reading of ip_frag_reasm() is that you can always use fragmen=
ts=20
list. If this happens the defragmentation code will split your skb into=
 two,=20
so as to avoid nested fragments. What's the problem with that?

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D


From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] igb: fix PHC stopping on max freq
Date: Wed, 20 Mar 2013 20:11:53 +0100
Message-ID: <20130320201153.7fc5e844@griffin>
References: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
	<CD6E221E.1657D%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Stefan Assmann <sassmann@redhat.com>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab3CTTMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 15:12:17 -0400
In-Reply-To: <CD6E221E.1657D%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Mar 2013 21:17:25 +0000, Vick, Matthew wrote:
> Good catch on this, Jiri! I know the math works out the same, but I'd
> prefer it if you changed the max_adj value to 999999999, since that is
> technically what we can accept before we have any issues. If you re-submit
> with this change, I'll add my ACK and we can run it through our internal
> testing. Thanks!

But the real maximum value is actually 999999881, as anything higher
than that would be capped to 999999881 by the driver. I don't think the
driver should advertise higher max_adj than it is able to fulfill,
otherwise there would be no need for the field.

 Jiri

-- 
Jiri Benc

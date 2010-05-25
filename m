From: Shirley Ma <mashirle@us.ibm.com>
Subject: RE: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Tue, 25 May 2010 02:37:19 -0700
Message-ID: <1274780239.18023.48.camel@localhost.localdomain>
References: <1274473846.8701.25.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
	 <1274720919.18023.19.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C0E05@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:44620 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597Ab0EYJhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 05:37:23 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755A79C0E05@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-24 at 10:54 -0700, Rose, Gregory V wrote:
> We look forward to it and will be happy to provide feedback.
I have submitted the patch to make macvlan on PF works when SRIOV is
enabled.

> One thing you can do is allocate VFs and then load the VF driver in
> your host domain and then assign each of them a macvlan filter.  You'd
> get a similar effect.

That's I am trying to make it work for macvlan on VFs in host domain. I
need to add VF secondary addresses in address filter, right?

Do you have any aggregation performance comparison between multiple
macvlans on PF and single macvlan per VF in host domain? I will run some
test to figure it out. If you have some data to share that would be
great.

Thanks
Shirley


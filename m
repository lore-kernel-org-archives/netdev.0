From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 13:15:26 -0700 (PDT)
Message-ID: <20091014.131526.181354809.davem@davemloft.net>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
	<200910141319.43884.bcook@bpointsys.com>
	<903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, brad.doctor@gmail.com, netdev@vger.kernel.org
To: deri@ntop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932342AbZJNUPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:15:30 -0400
In-Reply-To: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Deri <deri@ntop.org>
Date: Wed, 14 Oct 2009 21:54:26 +0200

> - packets to be filtered using both BPF and ACL-like filters

To me this is all that PF_RING adds, the ACL filter features.

And I see no reason why that can't be added to PF_PACKET, we've
extended PF_PACKET in many ways before (even the mmap ring
buffer layout can be modified trivially) so there is no reason
we can't add the ACL filter feature to PF_PACKET as well.

Adding all of PF_RING just for that is a joke.

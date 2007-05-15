From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 14:25:33 -0700
Message-ID: <ada8xbppynm.fsf@cisco.com>
References: <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, David Miller <davem@davemloft.net>,
	krkumar2@in.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:59691 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954AbXEOVfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:35:11 -0400
In-Reply-To: <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com> (Shirley Ma's message of "Tue, 15 May 2007 14:22:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Shirley>       I just wonder without TSO support in HW, how much
    Shirley> benefit we can get by pushing GSO from interface layer to
    Shirley> device layer besides we can do multiple packets in IPoIB.

The entire benefit comes from having multiple packets to queue in one
call to the xmit method.

 - R.

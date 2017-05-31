From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] arp: Really delete an arp entry on "arp -d"
Date: Wed, 31 May 2017 11:22:03 -0400
Message-ID: <20170531152203.GB9362@oracle.com>
References: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
 <20170530162020.137aef02@xeon-e3>
 <20170530233232.GL23089@oracle.com>
 <de8d048e-a276-c596-6b98-c9e7c4b91270@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39509 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdEaPWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:22:14 -0400
Content-Disposition: inline
In-Reply-To: <de8d048e-a276-c596-6b98-c9e7c4b91270@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/30/17 18:42), David Ahern wrote:
> It has been noticed. I have not sent a patch since adjusting gc
> parameters will reclaim FAILED entries at whatever rate the user wants.

Overly aggressive garbage collection will delete other (non-FAILED)
entries as well, and can trigger needless re-ARP (or re-ND), whereas
the admin may just want to lose some selective static arp/NCE entries.

--Sowmini

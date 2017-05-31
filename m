From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH V3] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Wed, 31 May 2017 18:07:57 -0400
Message-ID: <20170531220757.GI9362@oracle.com>
References: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com>
 <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31939 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdEaWIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 18:08:15 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/01/17 00:41), Julian Anastasov wrote:
> 
> 	So, we do not hold reference to neigh while accessing
> its fields. I suspect we need to move the table lock from
> neigh_remove_one here, for example:

Another thought is to have neigh_remove_one to remove
a neigh only if it is NUD_FAILED - that may potentially remove
more than one entry, but that's probably harmless?

--Sowmini

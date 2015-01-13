From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: fix rx packet length check to allow
 for TSO
Date: Tue, 13 Jan 2015 13:01:04 -0500
Message-ID: <20150113180104.GL28371@oracle.com>
References: <54B559A1.9010303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51231 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbAMSBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:01:08 -0500
Content-Disposition: inline
In-Reply-To: <54B559A1.9010303@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/13/15 12:45), David L Stevens wrote:
> 
> This patch fixes the rx packet length check in the sunvnet driver to allow
> for a TSO max packet length greater than the LDC channel negotiated MTU.
> These are negotiated separately and there is no requirement that
> port->tsolen be less than port->rmtu, but if it isn't, it'll drop packets
> with rx length errors.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

--Sowmini

From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 17:07:41 -0700
Message-ID: <1151712461.3645.12.camel@rh4>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4CB@nekter>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:58378 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S933020AbWGAAGf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 20:06:35 -0400
To: "Ananda Raju" <Ananda.Raju@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4CB@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-30 at 19:55 -0400, Ananda Raju wrote:
> True, I am referring to "ethtool -K ethX tso off"
> ethtool_op_set_tso() won't clear NETIF_F_TSO6 for ethtool -K ethX tso
> off
> 
Instead of using ethtool_op_set_tso() in your ethtool_ops structure, you
can use a private function to set or clear any new bits such as
NETIF_F_TSO6 or NETIF_F_TSO_ECN.


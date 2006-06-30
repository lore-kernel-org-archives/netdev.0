From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 16:52:58 -0700
Message-ID: <1151711578.3645.8.camel@rh4>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:8455 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S932562AbWF3Xvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:51:53 -0400
To: "Ananda Raju" <Ananda.Raju@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-30 at 19:44 -0400, Ananda Raju wrote:
> Hi, 
> 
> I tested the patch, and TSO over ipv6 is working fine. But TSO disable
> not working for IPv6. 
> 
You need to clear NETIF_F_TSO6 in dev->features to disable ipv6 TSO.


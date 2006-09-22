From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Date: Fri, 22 Sep 2006 11:46:37 +0100
Message-ID: <200609221146.37827@strip-the-willow>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63414 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S932112AbWIVKqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 06:46:51 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  This removes DCCP_SOCKOPT_PACKET_SIZE for two reasons:
|  * the current code doesn't work
|  * tx and rx should be different (introduced in former patch)

Agree that DCCP_SOCKOPT_PACKET_SIZE is redundant, patch looks good and
has been tested.

Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

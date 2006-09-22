From: Eddie Kohler <kohler@cs.ucla.edu>
Subject: Re: [PATCH 6/7] [DCCP]: Fix setting of packet size in CCID3
Date: Fri, 22 Sep 2006 09:57:57 -0700
Message-ID: <45141615.30908@cs.ucla.edu>
References: <200609221432.20022.ian.mcdonald@jandi.co.nz> <200609221151.57230@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-2.smtp.ucla.edu ([169.232.47.136]:55955 "EHLO
	smtp-2.smtp.ucla.edu") by vger.kernel.org with ESMTP
	id S932599AbWIVQ7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 12:59:49 -0400
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609221151.57230@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> |  +	case DCCP_SOCKOPT_TX_PACKET_SIZE:
> |  +		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
> |  +			err = -EINVAL;
> This is unfortunate: it is in the generic dccp code but
> works only for CCID 3. Same for DCCP_SOCKOPT_RX_PACKET_SIZE.

I agree with Gerrit.  An average packet size congestion control parameter 
might be useful for multiple CCIDs, even if only some CCIDs would use it. 
Would prefer that this sets the parameter in all cases.

E

> 
> 
> --Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

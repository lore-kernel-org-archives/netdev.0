From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 12/12] smc911x: afc_cfg calculation is wrong at case 5
Date: Thu, 14 Sep 2006 12:23:46 +0300
Message-ID: <200609141223.46286.bora.sahin@ttnet.net.tr>
References: <200609132137.47905.bora.sahin@ttnet.net.tr> <20060913190234.GG25007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:17468 "EHLO
	fep04.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751494AbWINJUF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 05:20:05 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060913190234.GG25007@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> > @@ -1977,7 +1975,7 @@
> >  		case 4:/* 11520 Rx Data Fifo Size */
> >  			lp->afc_cfg=0x00783C9F;break;
> >  		case 5:/* 10560 Rx Data Fifo Size */
> > -			lp->afc_cfg=0x006E374F;break;
> > +			lp->afc_cfg=0x006E378F;break;
> 
> Not your fault but the break statement is misplaced.

Or one space ahead? like 
	lp->afc_cfg=0x006E378F; break;

--
Bora SAHIN

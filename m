From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.21 1/3]S2IO: getringparam ethtool option
Date: Mon, 14 May 2007 01:00:54 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770194716C@nekter>
References: <4644D839.4070706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Alicia Pena" <Alicia.Pena@neterion.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
To: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:4898 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757350AbXENE7y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 00:59:54 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4644D839.4070706@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fwding to Ram, there was a typo in Ram's e-mail id. 


-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Saturday, May 12, 2007 2:25 AM
To: Sreenivasa Honnur
Cc: netdev@vger.kernel.org; Alicia Pena; Leonid Grossman;
ramkrishna.vep@neterion.com; Rastapur Santosh; Sivakumar Subramani
Subject: Re: [PATCH 2.6.21 1/3]S2IO: getringparam ethtool option

Sreenivasa Honnur wrote:
> Adding get_ringparam ethtool option.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

applied 1-3

Please send follow-up patch that removes braces around single C
statements:

> +	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
> +		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
> +	}



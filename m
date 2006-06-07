From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/9] NetXen 1G/10G ethernet driver patch with corrections
Date: Wed, 7 Jun 2006 11:49:51 +0200
Message-ID: <200606071149.51879.ak@suse.de>
References: <Pine.LNX.4.64.0606070237220.10031@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49586 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932114AbWFGJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 05:50:15 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0606070237220.10031@unmsrvr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 June 2006 11:39, Linsys Contractor Amit S. Kale wrote:

> +	switch (mode) {

... You could save a lot of code by using a table and a loop over the registers.


> +	case 4:{		/* XGB Mode */
> +			NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_XG_SINGLE_TERM,
> +						   &regs_buff[3]);


-Andi

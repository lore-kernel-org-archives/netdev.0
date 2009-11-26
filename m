From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 26 Nov 2009 00:58:02 -0800
Message-ID: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD28A7D6F76@HQ-EXCH-7.corp.brocade.com>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
 <20091123202815.1a8f67b2@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Akshay Mathur <amathur@brocade.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:18581 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbZKZI55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 03:57:57 -0500
In-Reply-To: <20091123202815.1a8f67b2@s6510>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, 

We made this change in our last submitted patch.

Thanks
--Debashis

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Monday, November 23, 2009 8:28 PM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Adapter Linux Open SRC Team
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +
> +/* Currently we assume just 2 columns, col 0 = small, col 1 = large */
> +u32 intr_mod_vector[BNA_LOAD_TYPES + 1][BNA_BIAS_TYPES] = {

static? const?

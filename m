From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] S2IO: Fixes for MSI and MSIX
Date: Tue, 27 Feb 2007 04:27:37 -0500
Message-ID: <45E3F989.2050007@garzik.org>
References: <Pine.GSO.4.10.10702240132020.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	sreenivasa.honnur@neterion.com, ramkrishna.vep@neterion.com,
	rastapur.santosh@neterion.com, alicia.pena@neterion.com,
	sriram.rapuru@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47527 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161086AbXB0J1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:27:41 -0500
In-Reply-To: <Pine.GSO.4.10.10702240132020.3434-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sivakumar Subramani wrote:
> - Added debug statements to print a debug message if the MSI/MSI-X vector (or)
>   data is zero.
> 
> - This patch removes the code that will enable NAPI for the case of single 
>   ring and MSI-X / MSI case. There are some issue in the enabling NAPI with
>   MSI/MSI-X.  So we are turning off NAPI in the case of MSI/MSI-X. 
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

applied 1-6, though turning off NAPI should be temporary, without a 
better explanation



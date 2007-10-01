From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] ehea: DLPAR memory add fix
Date: Mon, 1 Oct 2007 16:54:13 +0200
Message-ID: <200710011654.14067.ossthema@de.ibm.com>
References: <200710011633.18305.ossthema@de.ibm.com> <470107D9.2040301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:29822 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbXJAOyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:54:16 -0400
In-Reply-To: <470107D9.2040301@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Monday 01 October 2007 16:44, Jeff Garzik wrote:
> Jan-Bernd Themann wrote:
> > Due to stability issues in high load situations the HW queue handling
> > has to be changed. The HW queues are now stopped and restarted again instead
> > of destroying and allocating new HW queues. 
> > 
> > Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> 
> May I presume this is for 2.6.23?
> 
> 	Jeff

no, the patch is build against 2.6.24 upstream (new NAPI interface).

Regards,
Jan-Bernd

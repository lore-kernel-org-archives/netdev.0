From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH 3/4] ehea: queue managment
Date: Thu, 8 Jun 2006 09:35:33 +0300
Message-ID: <20060608063533.GB6343@rhun.haifa.ibm.com>
References: <4487073E.1020403@de.ibm.com> <20060607102950.54dd83c1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org,
	Marcus Eder <MEDER@de.ibm.com>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:32596 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP id S932530AbWFHGfg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 02:35:36 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k586ZZHZ087646
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 06:35:35 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k586akVc120410
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 07:36:46 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k586ZYfv003678
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 07:35:34 +0100
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060607102950.54dd83c1@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 10:29:50AM -0700, Stephen Hemminger wrote:

> Be careful about global namespace issues. Stick to one prefix like ehea_
> for all non static function names. Consider putting all in one file, or
> use #include to cause it to be one compilation unit.

I thought including .c files was discouraged (if not, it should be...)

Cheers,
Muli

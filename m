From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: ehea work queues
Date: Mon, 1 Oct 2007 16:43:04 +0200
Message-ID: <200710011643.04180.ossthema@de.ibm.com>
References: <20070930162019.GE28619@kryten>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: themann@de.ibm.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:53127 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbXJAOnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:43:33 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l91EhW20092204
	for <netdev@vger.kernel.org>; Mon, 1 Oct 2007 14:43:32 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91EhW6Z3121242
	for <netdev@vger.kernel.org>; Mon, 1 Oct 2007 15:43:32 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91EhF3G001789
	for <netdev@vger.kernel.org>; Mon, 1 Oct 2007 15:43:15 +0100
In-Reply-To: <20070930162019.GE28619@kryten>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Sunday 30 September 2007 18:20, Anton Blanchard wrote:
> 
> Hi,
> 
> I booted 2.6.23-rc8 and noticed that ehea loves its workqueues:
> (notice also that the ehea_driver_wq/XXX exceeds TASK_COMM_LEN). 
> 
> Since they are both infrequent events and not performance critical
> (memory hotplug and driver reset), can we just use schedule_work?
> 
Yes. I'll provide a patch soon.

Thanks,
Jan-Bernd

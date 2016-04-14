From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH] qlge: Replace create_singlethread_workqueue with
	alloc_ordered_workqueue
Date: Thu, 14 Apr 2016 07:25:15 +0000
Message-ID: <BLUPR11MB011498CD02CC919F023545E793970@BLUPR11MB0114.namprd11.prod.outlook.com>
References: <20160409115744.GA30104@amitoj-Inspiron-3542>
 <20160413174422.GB3676@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
To: Tejun Heo <tj@kernel.org>,
	Amitoj Kaur Chawla <amitoj1606@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0107.outbound.protection.outlook.com ([157.56.110.107]:24032
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751178AbcDNI52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 04:57:28 -0400
In-Reply-To: <20160413174422.GB3676@htj.duckdns.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
> [mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On Behalf
> Of Tejun Heo
> Sent: Wednesday, April 13, 2016 11:14 PM
> To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Cc: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>; netdev
> <netdev@vger.kernel.org>; linux-kernel <linux-kernel@vger.kernel.org>; Dept-
> Eng Linux Driver <Linux-Driver@qlogic.com>; Harish Patil
> <harish.patil@qlogic.com>; Dept-GE Linux NIC Dev <Dept-
> GELinuxNICDev@qlogic.com>
> Subject: Re: [PATCH] qlge: Replace create_singlethread_workqueue with
> alloc_ordered_workqueue
> 
> On Sat, Apr 09, 2016 at 05:27:45PM +0530, Amitoj Kaur Chawla wrote:
> > Replace deprecated create_singlethread_workqueue with
> > alloc_ordered_workqueue.
> >
> > Work items include getting tx/rx frame sizes, resetting MPI processor,
> > setting asic recovery bit so ordering seems necessary as only one work
> > item should be in queue/executing at any given time, hence the use of
> > alloc_ordered_workqueue.
> >
> > WQ_MEM_RECLAIM flag has been set since ethernet devices seem to sit in
> > memory reclaim path, so to guarantee forward progress regardless of
> > memory pressure.
> >
> > Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> > Acked-by: Tejun Heo <tj@kernel.org>
> 
> Ping?
> 

Hi,
Just want to confirm that __WQ_LEGACY flag is not necessary here as this is removed
with this change ? 

Thanks
 

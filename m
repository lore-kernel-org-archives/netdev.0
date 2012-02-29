From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Wed, 29 Feb 2012 00:18:59 -0800 (PST)
Message-ID: <1879896900.614230.1330503539675.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
References: <20120223104237.GA2127@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jongman Heo <jongman.heo@samsung.com>, netdev@vger.kernel.org,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:57055 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751211Ab2B2ITA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 03:19:00 -0500
In-Reply-To: <20120223104237.GA2127@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> (Heo, your mua broke threading)
> 
> Jongman Heo <jongman.heo@samsung.com> :
> > Francois Romieu<romieu@fr.zoreil.com>
> > > > Jongman Heo <jongman.heo@samsung.com> :
> > > > Following warning triggered with my VMware Linux guest, when
> > > > NFS connection is requested from outside.
> > > 
> > > I'd try reverting 39d4a96fd7d2926e46151adbd18b810aeeea8ec0.
> [...]
> > I confirm that reverting the commit fixes the warning.
> 
> Shreyas, can you provide a proper fix for this bug (see
> http://www.spinics.net/lists/netdev/msg189554.html for details).
> 
> As far as I understand it you can not claim a fake transport layer
> header
> size for udp and blindly check the available buffer size through
> pskb_may_pull later. With a 32 bits HIGHMEM guest config (yuck...) it
> ends
> up enabling bh within a network device start_xmit context.
> 
> --
> Ueimor
> 

Just sent a patch to fix the transport header size.

Thanks.
Shreyas

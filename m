From: Dan Carpenter <error27@gmail.com>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Sat, 21 Nov 2009 10:13:01 +0200
Message-ID: <20091121081301.GA17766@bicker>
References: <4B014F95.8000906@chelsio.com> <20091116.051835.125328285.davem@davemloft.net> <4B01577E.2020003@chelsio.com> <b263e5900911200529n1c002097q48a625d1bcda4db6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rakesh Ranjan <rakesh@chelsio.com>,
	David Miller <davem@davemloft.net>, michaelc@cs.wisc.edu,
	open-iscsi@googlegroups.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, James.Bottomley@suse.de,
	kxie@chelsio.com
To: Dan Carpenter <error27.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:54966 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbZKUINO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 03:13:14 -0500
Content-Disposition: inline
In-Reply-To: <b263e5900911200529n1c002097q48a625d1bcda4db6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 03:29:24PM +0200, Dan Carpenter wrote:
> On 11/16/09, Rakesh Ranjan <rakesh@chelsio.com> wrote:
> > David Miller wrote:
> >> From: Rakesh Ranjan <rakesh@chelsio.com>
> >> Date: Mon, 16 Nov 2009 18:41:49 +0530
> >>
> >>> Herein attached patches to support dhcp based provisioning for iSCSI
> >>> offload capable cards. I have made dhcp code as generic as possible,
> >>> please go through the code. Based on the feedback I will submit final
> >>> version of these patches.
> >>
> >> You can't really add objects to the build before the patch that
> >> adds the source for that object.
> >>
> >
> > Hi david,
> >
> > Fixed patch attached.

+       spin_unlock(&rcv_lock);                                                                                              
+                                                                                                                            
+drop:                                                                                                                       
+       kfree(pskb);                                                                                                         

This should be kfree_skb(pskb)

+out:                                                                                                                        
+       return rc;                                                                                                           
+}                                                                                                                           
+EXPORT_SYMBOL(libiscsi_ipconfig_recv);                                                                                      

regards,
dan carpenter

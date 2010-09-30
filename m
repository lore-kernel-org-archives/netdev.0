From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/2] enic: remove dead code
Date: Thu, 30 Sep 2010 11:49:58 +0900
Message-ID: <20100930114958.59c438d7@s6510>
References: <20100929152930.520cc3b4@s6510>
	<212AA327A3557741A058E787E0618873042E0BC6@xmb-sjc-219.amer.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Scott Feldman (scofeldm)" <scofeldm@cisco.com>,
	"Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"David Miller" <davem@davemloft.net>
To: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44268 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511Ab0I3CuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 22:50:05 -0400
In-Reply-To: <212AA327A3557741A058E787E0618873042E0BC6@xmb-sjc-219.amer.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Sep 2010 17:10:00 -0700
"Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com> wrote:

> Hi Stephen,
> 
>  
> 
> Thanks a lot for submitting this patch. However, I have got few
> concerns:
> 
>  
> 
> 1.       Need to retain vnic_dev_soft_reset and vnic_dev_soft_reset_done
> as they are used in vnic_dev_hang_reset and vnic_dev_hang_reset_done
> respectively
> 
> 2.       Want to retain enic_set_rss_key and enic_set_rss_cpu as we will
> be using those in the near future for adding multi rq functionality to
> enic. 
> 
> 3.       Additional cleanup in vnic_rss.h. FYI, the struct defines in
> vnic_rss.h are currently not in use. But I retained them for the same
> reason as in #2.

Ok, but Linux tree is not the repository for "possible future enhancements".
Do it or remove it.

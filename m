From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH v2 net-next 0/3 ] tunneling: Add support for hardware-offloaded
 encapsulation
Date: Tue, 13 Nov 2012 16:42:18 -0800 (PST)
Message-ID: <alpine.LFD.2.02.1211131514060.13310@morpheus.jf.intel.com>
References: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 12 Nov 2012, Joseph Gasparakis wrote:

> The series contains updates to add in the NIC Rx and Tx checksumming support
> for encapsulated packets.
> 
> The sk_buff needs to somehow have information of the inner packet, and adding
> three fields for the inner mac, network and transport headers was the prefered
> approach. 
> 
> Not adding these fields would mean that the drivers would need to parse the
> sk_buff data in hot-path, having a negative impact in the performance.
> 
> Adding in sk_buff a pointer to the skbuff of the inner packet made sense, but
> would be a complicated change as assumptions needed to be made with regards to
> helper functions such as skb_clone() skb_copy(). Also code for the existing
> encapsulation protocols (such as VXLAN and IP GRE) had to be reworked, so the
> decision was to have the simple approach of adding these three fields.
> 
> v2 Makes sure that checksumming for IP GRE does not take place if the offload flag is set in the skb's netdev features
> 

Thank you all. I am working now on implementing a demo using ixgbe and 
will re-submit soon this series of patches taking into consideration any 
open comments.

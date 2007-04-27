From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 and eepro100
Date: Fri, 27 Apr 2007 09:05:58 -0700
Message-ID: <46321F66.8030404@intel.com>
References: <20070428.005230.105332667.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20795 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047AbXD0QGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 12:06:01 -0400
In-Reply-To: <20070428.005230.105332667.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> Hello.
> 
> I heard that there is a plan to remove eepro100 driver from kernel,
> but from the IPv6 point of view, there are still some issues with
> e100 driver, which does not exist in eepro100.
> 
> We are using some e100/eepro100 devices, and we have found that
> we cannot pass the Conformance Test with e100 but with eepro100.
> 
> We have been having no chance to debug this issue so far, but
> I guess there are some bugs in link detection code in e100.

please, read the discussion we had yesterday on netdev.

Also, without knowing *what* your problems are with e100, we can't help you 
solving them too. If you bring your bugreport in detail to us at 
e1000-devel@lists.sf.net we can take it up and dig into it.

The conclusion is that the s-bit patch will be in 2.6.22, as well as an option 
to run the driver in IO register access mode. this seems to be sufficient for 
most of the people that had issues.

Auke

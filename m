From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: Question: Proper place for port details?
Date: Thu, 04 Oct 2012 20:12:21 -0700
Message-ID: <506E5015.4020309@gmail.com>
References: <506D4896.8080900@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raspl@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28666 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050Ab2JEDMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 23:12:23 -0400
In-Reply-To: <506D4896.8080900@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2012 01:28 AM, Stefan Raspl wrote:
> Some network device drivers are capable of collecting further
> information on the link partner, e.g. reporting details on the port
> in the adjacent switch. Is there a good place to make these
> available outside of the kernel? ethtool gives a bit of information
> like the link partner's speed or duplex mode. But is adding further
> information about the link partner to ethtool desired, or is there a
> better place somewhere else?
>
> Ciao,
> Stefan
IMHO, reporting details on a port should be reported by Ethtool.

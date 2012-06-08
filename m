From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: formal way to map from pf to vfs when using VT-d?
Date: Fri, 08 Jun 2012 14:41:38 -0600
Message-ID: <4FD26382.3050303@genband.com>
References: <4FD25D18.6090002@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:33631 "EHLO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759582Ab2FHUmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 16:42:05 -0400
In-Reply-To: <4FD25D18.6090002@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2012 02:14 PM, Chris Friesen wrote:
>
> Hi,
>
> I'm using the igb/igbvf drivers.  If I set igb.max_vfs=7,7,7,7 it 
> creates 7 vfs for each of my pfs.  So far so good.
>
> Now, how do I map from a given pf to the PCI addresses for the set of 
> vfs that are associated with it?  I don't have virsh installed, so is 
> there a way to query this with sysfs or something?
>

I think I found it.../sys/class/net/eth0/device/ has "virtfnX" entries 
which are symlinks to the appropriate pci address.

Chris

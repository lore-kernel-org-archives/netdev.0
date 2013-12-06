From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 06 Dec 2013 12:32:18 -0500 (EST)
Message-ID: <20131206.123218.1113571734746378151.davem@davemloft.net>
References: <52A166CB.4020508@pobox.com>
	<20131206170325.GA14254@xanatos>
	<20131206172947.GA13222@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sarah.a.sharp@linux.intel.com, mlord@pobox.com,
	linux-usb@vger.kernel.org, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3LFRcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:32:20 -0500
In-Reply-To: <20131206172947.GA13222@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 6 Dec 2013 09:29:47 -0800

> On Fri, Dec 06, 2013 at 09:03:25AM -0800, Sarah Sharp wrote:
>> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
>> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
>> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
>> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
>> > >>
>> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
>> > >>
>> > >> are available in the git repository at:
>> > >>
>> > >>
>> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
>> > > 
>> > > Pulled and pushed out, thanks.
>> > 
>> > Did this commit make it into linux-3.12.3 ?
>> > 
>> > I ask, because the NIC still locks up with that kernel,
>> > and even with the patch I had been using from David Laight.
>> > 
>> > Reverting the change that originally broke it still works though.
>> > Could we please get this reverted until such time as a reworked
>> > patch can be prepared for it?
>> 
>> Greg, can you please revert David's patch (commit 35773dac5f86 from your
>> usb-linus branch)?
> 
> Now reverted.

Please NO!

Merge the XHCI change, the change you have reverted actually fixes
things for some people and the XHCI change gets rid of the stated
regression.

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 3/3] e1000e: add support for new 82574L part
Date: Mon, 18 Aug 2008 12:53:06 -0700
Message-ID: <9929d2390808181253i55f5a4d0pae07e4a23eaba7d@mail.gmail.com>
References: <20080814003759.17449.58830.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080818160040.GA17369@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Bruce Allan" <bruce.w.allan@intel.com>
To: "Arthur Jones" <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:11995 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbYHRTxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 15:53:07 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3294475wfd.4
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 12:53:07 -0700 (PDT)
In-Reply-To: <20080818160040.GA17369@ajones-laptop.nbttech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 9:00 AM, Arthur Jones <ajones@riverbed.com> wrote:
> Hi Jeff, ...
>
> On Wed, Aug 13, 2008 at 05:38:44PM -0700, Jeff Kirsher wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> This new part has the same feature set as previous parts with the addition
>> of MSI-X support.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> I've applied this patch on top of your previous
> e1000e fixes to Friday's linus git tree and when
> I run the Tx Unit Hang test from:
>
> http://e1000.sourceforge.net/doku.php?id=tx_unit_hang
>
> I get a Tx Unit Hang after a few hours:
>
> 0000:03:00.0: eth4: Detected Tx Unit Hang:
>  TDH                  <ed>
>  TDT                  <ed>
>  next_to_use          <ed>
>  next_to_clean        <ff>
> buffer_info[next_to_clean]:
>  time_stamp           <100a2dd46>
>  next_to_watch        <1>
>  jiffies              <100a2e013>
>  next_to_watch.status <0>
>
> This is perhaps a dup of the e1000.sf.net bug
> 2040298 against the linux 2.6.26 + 0.4.1.7 intel
> e1000e driver:
>
> http://sourceforge.net/tracker/index.php?func=detail&aid=2040298&group_id=42302&atid=447449
>
> The system info is the same as in that bug, only
> the kernel and driver have changed...
>
> Arthur
> --

This is to be expected since these patches get the in kernel driver
updated or at least close to the out of kernel 0.4.1.7 driver.  We are
aware of the issue and we are currently working the issue.

Jesse is expecting to get you a patch today to test which should
resolve the issue.


-- 
Cheers,
Jeff

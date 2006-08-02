From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [2.6.18-rc2][e1000][swsusp] - Regression - Suspend to disk and
 resume breaks e1000 - RESOLVED Bug #6867
Date: Wed, 02 Aug 2006 08:06:08 -0700
Message-ID: <44D0BF60.4050905@intel.com>
References: <200607160509.52930.shawn.starr@rogers.com> <44BA6A4A.5090007@intel.com> <200608012355.28504.shawn.starr@rogers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52900 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751091AbWHBPIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 11:08:00 -0400
To: Shawn Starr <shawn.starr@rogers.com>
In-Reply-To: <200608012355.28504.shawn.starr@rogers.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shawn Starr wrote:
> On Sunday 16 July 2006 12:33 pm, Auke Kok wrote:
>> [adding netdev to the cc]
>>
>> unfortunately I didn't.
>>
>> e1000 has a special e1000_pci_save_state/e1000_pci_restore_state set of
>> routines that save and restore the configuration space. the fact that it
>> works for suspend to memory to me suggests that there is nothing wrong with
>> that.

> Hi Auke,
> 
> It appears 2.6.18-rc3 this does not occur anymore. I suspended to disk/ram and 
> the interface pci registers were restored. Bugzilla #6867

I would not be surprised if all the suspend issues in 2.6.18rcX were not 
involved in this somehow... thanks for reporting back in.

Auke

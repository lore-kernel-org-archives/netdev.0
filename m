From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] fm10k: Report MAC address on driver
 load
Date: Thu, 18 Jun 2015 19:23:48 -0700
Message-ID: <55837D34.7070100@gmail.com>
References: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22> <1434671381.3530.81.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35542 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbFSCXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 22:23:50 -0400
Received: by pacyx8 with SMTP id yx8so74267219pac.2
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 19:23:50 -0700 (PDT)
In-Reply-To: <1434671381.3530.81.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2015 04:49 PM, Jeff Kirsher wrote:
> On Wed, 2015-06-17 at 20:12 -0700, Alexander Duyck wrote:
>> This change adds the MAC address to the list of values recorded on
>> driver
>> load.  The MAC address represents the serial number of the unit and
>> allows
>> us to track the value should a card be replaced in a system.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>   drivers/net/ethernet/intel/fm10k/fm10k_pci.c |    4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
> With the recent fm10k patches that Jake submitted, this patch no longer
> applies cleanly.  If you could re-spin your patch against my next-queue
> tree (dev-queue branch) that would be much appreciated.

I should have a new patch for you in 20 minutes or so.  Just waiting on 
the build to finish and then I'll give it a quick test.

- Alex

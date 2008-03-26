From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH] e1000e: test MSI interrupts
Date: Wed, 26 Mar 2008 13:42:50 -0700
Message-ID: <47EAB54A.1060306@intel.com>
References: <20080326183631.25114.90265.stgit@localhost.localdomain> <47EA9911.8040101@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58553 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755859AbYCZUoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 16:44:09 -0400
In-Reply-To: <47EA9911.8040101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>> Test the MSI interrupt physically once before assuming that it
>> actually works. Several platforms have already come across that
>> have non-functional MSI interrupts and this code will attempt
>> to detect those safely. Once the test succeeds MSI interrupts
>> will be enabled.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000e/defines.h |    1 
>>  drivers/net/e1000e/e1000.h   |    1 
>>  drivers/net/e1000e/netdev.c  |  161 ++++++++++++++++++++++++++++++++++++++++--
>>  3 files changed, 155 insertions(+), 8 deletions(-)
> 
> Ah, the perennial add-same-test-to-every-driver conundrum.
> 
> I think we are far enough along with MSI to _not_ do this anymore in 
> drivers.
> 
> The platforms with MSI problems should be discovered, made public, and 
> worked around.
> 
> Otherwise you hide the same problem, just for someone else to discover 
> with another component of the machine.

ok, that's reasonable as I have not recently seen any "new" reports against the
current trees.

We have to keep this patch in our out-of-tree version around though, since a lot
of distros still ship kernels without all the new MSI quirks. But that's not for
this forum.

Thanks,

Auke


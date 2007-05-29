From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/7 RESEND] cxgb3 - Update FW to 4.1
Date: Tue, 29 May 2007 15:38:21 -0700
Message-ID: <465CAB5D.7060405@chelsio.com>
References: <20070526231748.12319.20729.stgit@localhost.localdomain> <465B5A8B.7000701@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751766AbXE2Wit@vger.kernel.org>
In-Reply-To: <465B5A8B.7000701@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> divy@chelsio.com wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Bump FW version to 4.1.
>> Modify chip tuning in consequence.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>> ---
>>
>>  drivers/net/cxgb3/regs.h    |    4 ++++
>>  drivers/net/cxgb3/t3_hw.c   |   40 
>> ++++++++++++++++++++++------------------
>>  drivers/net/cxgb3/version.h |    2 +-
>>  3 files changed, 27 insertions(+), 19 deletions(-)
>
> You think requiring a FIRMWARE UPGRADE is something that should be 
> done in the middle of a kernel bugfix series?  What Q/A planet are you 
> from?

I made a bad jugdement.
I'll repost a patch series for 2.6.22 fixes against Linus'tree, and a 
patch series for driver improvements against netdev-2.6#upstream, if it 
is acceptable.

>
> This is a completely ridiculous burden you are placing on the 
> individual user.  A good driver knows that firmware NOT SHIPPED WITH 
> THE KERNEL does not necessarily move in lock-step with the kernel driver.

We're actively working on RDMA improvements, leading to these FW updates.
Some of the changes are unfortunately not backward compatible, hence the 
exact matching the driver enforces.
The bundle driver/FW is getting finalized. New adapters will be shipped 
with the right image once it is available.
In the mean time, this is indeed a burden for the current users to get 
the corresponding FW.

Divy

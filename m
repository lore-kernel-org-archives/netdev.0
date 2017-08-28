From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] connector: Delete an error message for a failed memory
 allocation in cn_queue_alloc_callback_entry()
Date: Mon, 28 Aug 2017 14:05:14 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F07797141@ORSMSX103.amr.corp.intel.com>
References: <7b206228-b3e9-5cb9-873c-75b5d8aae23b@users.sourceforge.net>
 <E0D909EE5BB15A4699798539EA149D7F0779689E@ORSMSX103.amr.corp.intel.com>
 <20170828060545.yddjpqzitw46lgiu@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Evgeniy Polyakov <zbr@ioremap.net>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/28/17 2:06 AM, Dan Carpenter wrote:
> On Sun, Aug 27, 2017 at 11:16:06PM +0000, Waskiewicz Jr, Peter wrote:
>> On 8/27/17 3:26 PM, SF Markus Elfring wrote:
>>> From: Markus Elfring <elfring@users.sourceforge.net>
>>> Date: Sun, 27 Aug 2017 21:18:37 +0200
>>>
>>> Omit an extra message for a memory allocation failure in this function.
>>>
>>> This issue was detected by using the Coccinelle software.
>>
>> Did coccinelle trip on the message or the fact you weren't returning NULL?
>>
> 
> You've misread the patch somehow.  The existing code has a NULL return
> and it's preserved in Markus's patch.  This sort of patch is to fix a
> checkpatch.pl warning.  The error message from this kzalloc() isn't going
> to get printed because it's a small allocation and small allocations
> always succeed in current kernels.  But probably the main reason
> checkpatch complains is that kmalloc() already prints a stack trace and
> a bunch of other information so the printk doesn't add anyting.
> Removing it saves a little memory.
> 
> I'm mostly a fan of running checkpatch on new patches or staging and not
> on old code...

And this is what I get for reading the patch with a crappy 
mailer...thanks Doubtlook.

Sorry for the noise.

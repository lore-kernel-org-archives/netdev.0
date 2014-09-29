From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8821ae: Remove driver from staging
Date: Mon, 29 Sep 2014 13:08:21 -0500
Message-ID: <5429A015.1000700@lwfinger.net>
References: <1411954791-23779-1-git-send-email-Larry.Finger@lwfinger.net>
 <20140929170519.GA19823@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140929170519.GA19823@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 09/29/2014 12:05 PM, Greg KH wrote:
> On Sun, Sep 28, 2014 at 08:39:51PM -0500, Larry Finger wrote:
>> A new version of this driver has been merged into the wireless-testing tree
>> as commit 21e4b0726dc671c423e2dc9a85364716219c4502. It is both possible and
>> desirable to delete the staging version to avoid build errors in linux-next.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>
>> Greg,
>>
>> This removal patch was generated after commit 368c75b98bdfdfad54e7f165016819ef344e3587.
>> It should apply to your tree unless further modifications have been made to
>> the staging driver.
>
> Something is odd with this patch, it doesn't apply, even against that
> commit id:
> Applying: staging: r8821ae: Remove driver from staging
> error: patch failed: drivers/staging/rtl8821ae/btcoexist/HalBtc8812a1Ant.c:1
> error: drivers/staging/rtl8821ae/btcoexist/HalBtc8812a1Ant.c: patch does not apply
> Patch failed at 0001 staging: r8821ae: Remove driver from staging
> The copy of the patch that failed is found in:
>     /home/gregkh/linux/work/staging/.git/rebase-apply/patch
> When you have resolved this problem, run "git am --continue".
> If you prefer to skip this patch, run "git am --skip" instead.
> To restore the original branch and stop patching, run "git am --abort".
>
> Can you refresh against the staging-next branch of staging.git and try it
> again?  Or I can just delete it "by hand" which is fine with me, and might be
> easier fro you, just let me know.

I was on the staging-next branch, but when I pulled after receiving this mail, I 
got a conflict due to some change in drivers/staging/rtl8821ae/pci.c. That one 
must have been in your local copy, but not yet pushed when I pulled.

If you don't mind doing the delete there, the traffic on the Cc sites will be 
reduced. I'm sure you know what is needed, but just in case, delete the files in 
drivers/staging/rtl8821ae/ and the Makefile and Kconfig entries in drivers/staging/.

Thanks,

Larry


Larry

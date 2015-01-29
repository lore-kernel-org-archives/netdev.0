From: Behan Webster <behanw@converseincode.com>
Subject: Re: [PATCH] net, ethernet, LLVMLinux: Add missing MODULE_DEVICE_TABLE()
Date: Thu, 29 Jan 2015 10:21:01 -0800
Message-ID: <54CA7A0D.8000104@converseincode.com>
References: <1422495374-22835-1-git-send-email-behanw@converseincode.com> <20150128.224228.1533046356464752424.davem@davemloft.net> <3392784.h8cmHX9fyr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3392784.h8cmHX9fyr@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/15 01:10, Arnd Bergmann wrote:
> On Wednesday 28 January 2015 22:42:28 David Miller wrote:
>> From: Behan Webster <behanw@converseincode.com>
>> Date: Wed, 28 Jan 2015 17:36:14 -0800
>>
>>> Missing MODULE_DEVICE_TABLE for pci ids from benet driver found by clang.
>>>
>>> Signed-off-by: Behan Webster <behanw@converseincode.com>
>>> Suggested-by: Arnd Bergmann <arnd@arndb.de>
>> Why are you removing the device table?
> Behan took a patch that I did earlier and split it up to add descriptions.
> The patch is correct, but he either misunderstood or misexpressed the
> intention.
I was tired and rushed this submission in my preparation for FOSDEM.
Apologies to all.

I neglected to write the commit log when I first split the patch, and
didn't look hard enough this time.

> This driver has two identical lines that both say 
>
> MODULE_DEVICE_TABLE(pci, be_dev_ids);
This is indeed the case.

> I don't remember the exact symptom, but llvm/clang trips over this, while gcc
> silently ignores the second one.
It claims that it is defined more than once.

Behan

-- 
Behan Webster
behanw@converseincode.com

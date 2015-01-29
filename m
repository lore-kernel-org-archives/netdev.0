From: Behan Webster <behanw@converseincode.com>
Subject: Re: [PATCH] net, ethernet, LLVMLinux: Add missing MODULE_DEVICE_TABLE()
Date: Thu, 29 Jan 2015 10:25:09 -0800
Message-ID: <54CA7B05.3000300@converseincode.com>
References: <1422495374-22835-1-git-send-email-behanw@converseincode.com> <20150128.224228.1533046356464752424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150128.224228.1533046356464752424.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/15 22:42, David Miller wrote:
> From: Behan Webster <behanw@converseincode.com>
> Date: Wed, 28 Jan 2015 17:36:14 -0800
>
>> Missing MODULE_DEVICE_TABLE for pci ids from benet driver found by clang.
>>
>> Signed-off-by: Behan Webster <behanw@converseincode.com>
>> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Why are you removing the device table?
It is defined more than once; removing the duplicate (as Arnd
indicated). My commit message was just completely wrong. Brain fart. Sorry.

> Second of all, your Subject needs to be adjusted, using "net" and
> "LLVMLinux" in your subsystem prefix is not appropriate.  Simply
> "be2net: ", the name of this driver, is sufficient.
Will fix.

I've been in the habit of labelling the patches which go through the
LLVMLinux project like this so they are trivially identifiable in the
subject on lkml for reviewers and in the git log as being patches which
exist because of clang. If it's annoying I certainly don't need to do it.

Behan

-- 
Behan Webster
behanw@converseincode.com

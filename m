From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH, net-next] i40e: avoid 64-bit division where possible
Date: Tue, 17 Oct 2017 17:46:37 +0200
Message-ID: <CAK8P3a0qz3or0kcwzzXToQaa42794f4x_Wjcht-BftOypQX8mQ@mail.gmail.com>
References: <20171017102351.492492-1-arnd@arndb.de> <1508253294.2928.2.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jacob Keller <jacob.e.keller@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Amritha Nambiar <amritha.nambiar@intel.com>,
        Filip Sadowski <filip.sadowski@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508253294.2928.2.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 5:14 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Tue, 2017-10-17 at 12:23 +0200, Arnd Bergmann wrote:
>> The new bandwidth calculation causes a link error on 32-bit
>> architectures, like
>>
>> ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko]
>> undefined!

> Unfortunately your patch does not apply cleanly to my tree.  Arnd,
> could you please rebase your patch based my next-queue tree (dev-queue
> branch)?  I already have several i40e patches queued up and applied to
> that branch.

I see you already applied a fix from Alan Brady on that branch. I think
his version is sufficient to avoid the build problems, but mine is better.
I've rebased my patch now to revert parts of his fix. Please decide for
yourself whether you want to apply it on top, or are happy enough with
the existing version.

       Arnd

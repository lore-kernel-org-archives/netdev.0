From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] stmmac: pci: Refactor DMI probing
Date: Wed, 31 May 2017 12:32:02 -0400 (EDT)
Message-ID: <20170531.123202.240107293094153046.davem@davemloft.net>
References: <cover.1496129604.git.jan.kiszka@siemens.com>
        <CAHp75VcGNr78mfGgtrKuZJtLppv=rAJ4Bxejcec3MhnC6ejSjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.kiszka@siemens.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VcGNr78mfGgtrKuZJtLppv=rAJ4Bxejcec3MhnC6ejSjQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue, 30 May 2017 21:48:05 +0300

> On Tue, May 30, 2017 at 10:33 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>> Some cleanups of the way we probe DMI platforms in the driver. Reduces
>> a bit of open-coding and makes the logic easier reusable for any
>> potential DMI platform != Quark.
>>
>> Tested on IOT2000 and Galileo Gen2.
> 
> So, for patches 1-4,
> Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
> 
> I'm not convinced that patch 6 is needed, so, my vote is not to include it.
> 
> Patch 5 I would like to review later. Main problem to me is {-1, -1}.
> It looks non-standard and feels not good. I'll try to think on the
> solution.

Ok, so at a minimum I'm expecting another respin of this.

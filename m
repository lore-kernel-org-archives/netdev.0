From: viresh kumar <viresh.kumar2@arm.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 09:08:34 +0100
Message-ID: <4FE18502.6040409@arm.com>
References: <20120620133348.a9ff31a72ffd11818f574fe3@canb.auug.org.au> <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Federico Vaga <federico.vaga@gmail.com>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	spear-devel <spear-devel@list.st.com>
To: Bhupesh SHARMA <bhupesh.sharma@st.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FAA275CA8@EAPEX1MAIL1.st.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/06/12 05:27, Bhupesh SHARMA wrote:
>> -----Original Message-----
>> From: Stephen Rothwell [mailto:sfr@canb.auug.org.au]
>> Sent: Wednesday, June 20, 2012 9:04 AM
>> To: David Miller; netdev@vger.kernel.org
>> Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Federico
>> Vaga; Giancarlo ASNAGHI; Wolfgang Grandegger; Bhupesh SHARMA; Marc
>> Kleine-Budde
>> Subject: linux-next: build failure after merge of the net-next tree
>>
>> Hi all,
>>
>> After merging the net-next tree, today's linux-next build (x86_64
>> allmodconfig) failed like this:
>>
>> ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_pci.ko] undefined!
>> ERROR: "clk_get" [drivers/net/can/c_can/c_can_pci.ko] undefined!
>> ERROR: "clk_put" [drivers/net/can/c_can/c_can_pci.ko] undefined!
>>
>> Caused by commit 5b92da0443c2 ("c_can_pci: generic module for
>> C_CAN/D_CAN on PCI").  Maybe a missing Kconfig dependency/select?
>>
>> I have used the net-next tree from next-20120619 for today.
>> --
>
> clk_get/clk_put* variants are usually used by ARM platforms.
> Protecting their calls under macro 'CONFIG_HAVE_CLK' should solve the problem.
>
> See [1] for how it is done in c_can_platform.c
>
> Could you possibly add these checks and send a patch for the same?
> It should be fairly simple.

Hi Bhupesh,

Please see following patchset from me, that got applied in linux-next

https://lkml.org/lkml/2012/4/24/154

Please check if this patchset is present in your build repo. I believe it should be
there. If it is, then you shouldn't get these errors.

--
viresh

-- IMPORTANT NOTICE: The contents of this email and any attachments are confidential and may also be privileged. If you are not the intended recipient, please notify the sender immediately and do not disclose the contents to any other person, use it for any purpose, or store or copy the information in any medium.  Thank you.

From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [net-next 1/1] bna: Multiple Definition and Interface Setup Fix
Date: Wed, 05 Oct 2011 10:09:17 -0700
Message-ID: <4E8C8F3D.8040605@xenotime.net>
References: <1317781880-26515-1-git-send-email-rmody@brocade.com>	<20111004.232713.1345786533613742751.davem@davemloft.net> <20111005192601.fa947a78b188f4a021042a5e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rmody@brocade.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	huangj@brocade.com, adapter_linux_open_src_team@brocade.com,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111005192601.fa947a78b188f4a021042a5e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/11 01:26, Stephen Rothwell wrote:
> On Tue, 04 Oct 2011 23:27:13 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>>
>> From: Rasesh Mody <rmody@brocade.com>
>> Date: Tue, 4 Oct 2011 19:31:20 -0700
>>
>>> drivers/net/built-in.o: In function `bfa_ioc_ct2_poweron':
>>> (.text+0xcdc90): multiple definition of `bfa_ioc_ct2_poweron'
>>> drivers/scsi/built-in.o:(.text+0x17f9a0): first defined here
>>>
>>> This patch renames bfa_ioc_ct2_poweron() to bfa_nw_ioc_ct2_poweron() to avoid
>>> multiple definition with Brocade scsi driver. It also modifies asic specific
>>> interface setup to allocate MSIX resources at power on in case of 1860 HW with
>>> no asic block and warns if the asic gen is neither BFI_ASIC_GEN_CT nor
>>> BFI_ASIC_GEN_CT2.
>>>
>>> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
>>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>>
>> Applied, thanks.

Thanks for the patch.

> I also manually applied this to linux-next today.

We could also stand to have this patch applied to linux-next since
it doesn't seem to be merged anywhere else yet: (for drivers/media/video)

http://marc.info/?l=linux-next&m=131741851601754&w=2


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Mon, 2 Aug 2004 10:26:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <578EC36E-E498-11D8-939F-000393DBC2E8@freescale.com>
References: <9DFF23E1E33391449FDC324526D1F25902833769@sjc1exm02.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>, <tmattox@gmail.com>,
        <hadi@cyberus.ca>, Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <9DFF23E1E33391449FDC324526D1F25902833769@sjc1exm02.pmc_nt.nt.pmc-sierra.bc.ca>
To: Manish Lachwani <Manish_Lachwani@pmc-sierra.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I want to say an internal group in Freescale has seen similar style 
performance improvements for integrated gig-e controllers in 2.4.

- kumar

On Jul 30, 2004, at 3:31 PM, Manish Lachwani wrote:

> Is this a 2.6 issue or a 2.4 issue? This is because I am using 2.4.21 
> kernel and so do the customers of the board. This board supports 1.0 
> Ghz PMC-Sierra Rm9000 processor. With fast routing, the IP forwarding 
> numbers are about 900 Kpps. While in the case where there is no fast 
> routing, the numbers are about 450 Kpps (NAPI enabled)
>
> I still have not done any 2.6 benchmarking since the board support is 
> not completely functional in 2.6 as yet.
>
> Thanks
> Manish
>
> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca]
> Sent: Friday, July 30, 2004 1:35 PM
> To: Manish Lachwani
> Cc: Jeff Garzik; tmattox@gmail.com; netdev@oss.sgi.com; Ralf Baechle
> Subject: Re: [RFC,PATCH] fastroute dead code...
>
>
> On Fri, 2004-07-30 at 16:10, David S. Miller wrote:
>> On Fri, 30 Jul 2004 15:35:15 -0400
>> Jeff Garzik <jgarzik@pobox.com> wrote:
>>
>>> It is dead code, as-is, in the kernel.  It would require patches to
>>> actually work at all.
>>>
>>> It is impossible that fastrouting is being actively used, without 
>>> patches.
>>
>> I totally agree.  And people can always resurrect it from the
>> repository history or an old tarball if they wish.
>
> Patches are needed for the driver to use that code. So its not entirely
> dead code i.e it is referenced from fastroute enabled drivers.
> Sample (really old) code found at:
> http://ftp.iasi.roedu.net/mirrors/ftp.inr.ac.ru/ip-routing/fastroute/
>
>
>> I think it should be killed entirely, and that's what I'm going
>> to do.
>
> Nod from here.
> Before you kill it lets hear from Ralf who is acquinted with someone
> that uses it and sings praises of it (although i personaly dont believe
> it ;->).
>
> cheers,
> jamal

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] coccinelle: api: check for propagation of error from
 platform_get_irq
Date: Sun, 27 Dec 2015 14:18:44 +0300
Message-ID: <567FC914.4080705@cogentembedded.com>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr>
 <567EF188.7020203@cogentembedded.com>
 <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6>
 <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
 <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
 <567F141C.8010000@cogentembedded.com>
 <alpine.DEB.2.02.1512262330430.2070@localhost6.localdomain6>
 <567F166B.7030208@cogentembedded.com>
 <alpine.DEB.2.02.1512270709420.2038@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gilles Muller <Gilles.Muller@lip6.fr>,
	Nicolas Palix <nicolas.palix@imag.fr>,
	Michal Marek <mmarek@suse.com>, cocci@systeme.lip6.fr,
	linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, linux-i2c@vger.kernel.org,
	linux-spi@vger.kernel.org, dri-devel@lists.freedesktop.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1512270709420.2038@localhost6.localdomain6>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/27/2015 9:13 AM, Julia Lawall wrote:

>>     Well, looking again, the patch should be good. I just thought its goal was
>> to fix the code as well...
>
> I could do that for the irq < 0 case, but I think that in that case, kbuild
> will only run the patch version, and the <= cases will not be reported on.
> I don't have a general fix for the <= 0.  Is it even correct to have < in
> some cases and <= in others?

    That's a good question...
    In my prior fixes of this case I preferred to consider IRQ0 valid and so 
used 'irq < 0'. I myself don't share the "IRQ0 is invalid" sentiment...

> julia

MBR, Sergei


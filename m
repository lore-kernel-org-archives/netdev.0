From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: Is via-velocity broken in 2.6.34?
Date: Sat, 11 Sep 2010 16:53:18 -0600
Message-ID: <4C8C085E.4050200@gmail.com>
References: <AANLkTi=kbonQ11mLpkd4EnSr3ch8yDssnjaUsgw_tVw9@mail.gmail.com>	<20100908.083022.189687100.davem@davemloft.net>	<AANLkTimRPOD857-pFXUJPxBw0RYXYe8OiPFwisY28x5B@mail.gmail.com> <20100909.125710.226781968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: matt.causey@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100909.125710.226781968.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/2010 01:57 PM, David Miller wrote:
> From: Matt Causey<matt.causey@gmail.com>
> Date: Thu, 9 Sep 2010 10:42:21 -0700
>
>> So it wasn't immediately intuitive that we would need power
>> management enabled in order to use other parts of the system.
>
> ACPI is not power management.
>
> It's a set of infrastructure (including an interpreter and small
> firmware programs to drive specialized hardware) that allows the
> important details of your motherboard to be described accurately to
> the kernel by firmware authors.
>
> That's why it's called "Advanced Configuration and Power Interface"
> and not just "Advanced Power Interface" :-)
>
> It also provides more accurate tables to describe things like
> the cpus in your system etc., to replace deprecated mechanisms
> for that such as MPS.

I'd think we'd save some trouble if we forced ACPI to on unless EMBEDDED 
was set or something, to indicate you shouldn't turn it off unless you 
really know what you're doing..

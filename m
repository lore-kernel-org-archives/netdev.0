From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Mon, 16 Jan 2012 08:35:09 -0800
Message-ID: <4F1451BD.9030904@linux.intel.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF47@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Darren Hart <dvhart@linux.intel.com>,
	Alan Cox <alan@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF47@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/2012 8:20 AM, David Laight wrote:
>  
>> the tricky thing with embedded hw like this is that all devices might
>> end up with the same, read-only filesystem, so storing the 
>> mac on the FS
>> and then loading it from there into the HW is... suboptimal.
>>
>> Would be very nice if busybox had a command that would check the mac
>> from each IF, and created the random mac from userspace 
>> automatically...
> 
> Since multiple interfaces on a single system are unlikely
> to be connected to the same LAN segment, it doesn't really
> matter if they use same MAC address.

I think you missed the point. All embedded devices have the same fs, so
if you have 2 boxes of the same model/brand on the same network, they'd
have the same MAC. That's generally frowned upon by network
administrators ;-)

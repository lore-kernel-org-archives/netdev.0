From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Sat, 14 Jan 2012 14:36:07 -0800
Message-ID: <4F120357.3020808@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001430.787918662083526597.davem@davemloft.net> <4F11A533.4040406@linux.intel.com> <20120114.115604.2101782124431552110.davem@davemloft.net> <20120114214658.4ddfec30@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	arjan@linux.intel.com, alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120114214658.4ddfec30@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/14/2012 01:46 PM, Alan Cox wrote:
>> I fear that people are just going to add this random MAC stuff way too
>> easily, it's a spreading disease.
>>
>> Ship functional hardware instead.
> 
> See "choir, preaching to the".
> 
> The stuff is out there and it's not Darren's fault !
> 
> Alan


So perhaps I should provide some more context into why I'm sending these
patches. The following hardware is currently available and the existing
Linux support is confined to a Timesys Fedora-Based pre-installed image
which requires user intervention to write a MAC using an old, not
upstreamed, modified ioh_gbe_mac driver.

The board documentation is available here:
http://www.inforcecomputing.com/SYS940X_ECX.html

In particular, see:
http://www.inforcecomputing.com/proddls/SYS940X-01_UserGuide_001329.pdf
and:
http://www.inforcecomputing.com/proddls/BLDK2_Kern_2.6.29-10_and_2.6.29-12_for_SYS940X-1_1304.pdf

I felt this patch made this hardware more accessible by allowing it to
work with current kernels without ugly userspace hacks. It is also
following precedent set by existing drivers.

So while I completely agree with the sentiment "Ship functional
hardware", this wasn't a product I was involved with, I'm just trying to
make a bad situation better. As Alan alludes to above, I do actually
spend a good deal of time trying to improve hardware to avoid this kind
of thing (it's an amazingly difficult task).

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel

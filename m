From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Mon, 16 Jan 2012 08:07:43 -0800
Message-ID: <4F144B4F.7050905@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001430.787918662083526597.davem@davemloft.net> <4F11A533.4040406@linux.intel.com> <20120114.115604.2101782124431552110.davem@davemloft.net> <20120114214658.4ddfec30@pyramind.ukuu.org.uk> <4F120357.3020808@linux.intel.com> <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com> <20120116123110.7ce91f2d@bob.linux.org.uk> <4F14457F.8060509@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F14457F.8060509@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/2012 7:42 AM, Darren Hart wrote:

> One reason I don't care for this alternative approach is that this
> particular hardware is targeted at embedded use where we can't assume a
> full init system is available, etc. It can be made to work of course, it
> just isn't as automated.
> 

the tricky thing with embedded hw like this is that all devices might
end up with the same, read-only filesystem, so storing the mac on the FS
and then loading it from there into the HW is... suboptimal.

Would be very nice if busybox had a command that would check the mac
from each IF, and created the random mac from userspace automatically...

From: Sam Leffler <sam@errno.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 10:00:18 -0800
Message-ID: <43CBDF32.50109@errno.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060116152312.6b9ddfd0@griffin.suse.cz> <1137423355.2520.112.camel@localhost> <20060116173325.GC8596@shaftnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751149AbWAPR7D@vger.kernel.org>
To: Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060116173325.GC8596@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stuffed Crust wrote:
> On Mon, Jan 16, 2006 at 03:55:55PM +0100, Johannes Berg wrote:
> 
>>I really don't see why a plain STA mode card should be required to carry
>>around all the code required for AP operation -- handling associations
>>of clients, powersave management wrt. buffering, ... Sure, fragmentation
> 
> 
> From the perspective of the hardware driver, there is little AP or 
> STA-specific code, especially when IBSS is thrown in.  Thick MACs 
> excepted, there's little more than "frame tx/rx, and hardware control 
> twiddling".  
> 
> The AP/STA smarts happen in the 802.11 stack.  And, speaking from 
> experience, it is very hard to separate them cleanly, at least not 
> without incurring even more overall complexity and bloat.
> 
> It's far simpler to build them intertwined, then add a bunch of #ifdefs 
> if you want to disable AP or STA mode individually to save space.

Perhaps you haven't hit some of the more recent standards that place 
more of a burden on the ap implementation?  Also some vendor-specific 
protocol features suck up space for ap mode only and it is nice to be 
able to include them only as needed.

There are several advantages to splitting up the code such as reduced 
audit complexity and real space savings but I agree that it is an open 
question whethere there's a big gain to modularizing the code by 
operating mode.

	Sam

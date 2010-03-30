From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/17] pcmcia: update gfp/slab.h includes
Date: Tue, 30 Mar 2010 10:01:47 +0900
Message-ID: <4BB14D7B.4010602@kernel.org>
References: <1269885165-18617-1-git-send-email-tj@kernel.org>	<1269885165-18617-10-git-send-email-tj@kernel.org>	<20100329193203.GA8450@comet.dominikbrodowski.net> <20100330103129.b76a70e3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100330103129.b76a70e3.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 03/30/2010 08:31 AM, Stephen Rothwell wrote:
> Hi Dominik,
> On Mon, 29 Mar 2010 21:32:03 +0200 Dominik Brodowski <linux@dominikbrodowski.net> wrote:
>>
>> On Tue, Mar 30, 2010 at 02:52:37AM +0900, Tejun Heo wrote:
>>> Implicit slab.h inclusion via percpu.h is about to go away.  Make sure
>>> gfp.h or slab.h is included as necessary.
>>>
>>> Signed-off-by: Tejun Heo <tj@kernel.org>
>>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>>> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
>> Acked-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
> The plan here is for you to put this in your tree now.  It is safe to do
> so and Tejun can't carry it because this does not apply to mainline. 

Yeap, something I completely forgot about when I asked Stephen to pull
from the slabh tree.  It would be great if you can apply this one and
Stephen's patches on drivers/input/misc/ad714x.c and pcf8574_keypad.c
into input tree.

Thank you.

-- 
tejun

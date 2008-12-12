From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fix double release of mutex
Date: Thu, 11 Dec 2008 20:51:37 -0800
Message-ID: <9929d2390812112051p2fcaaa22lcb8ae3edcb1ed2d3@mail.gmail.com>
References: <20081211215806.1173.24413.stgit@lost.foo-projects.org>
	<20081211.203119.180062878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, frederik.deweerdt@xprog.eu,
	akpm@linux-foundation.org, zdenek.kabelac@gmail.com, stable@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081211.203119.180062878.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 11, 2008 at 8:31 PM, David Miller <davem@davemloft.net> wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 11 Dec 2008 13:58:07 -0800
>
>> During a reset, releasing the swflag after it failed to be acquired would
>> cause a double unlock of the mutex.  Instead, test whether acquisition of
>> the swflag was successful and if not, do not release the swflag.  The reset
>> must still be done to bring the device to a quiescent state.
>>
>> This resolves [BUG 12200] BUG: bad unlock balance detected! e1000e
>> http://bugzilla.kernel.org/show_bug.cgi?id=12200
>>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> If we're fixing a regression like this, you should make the
> patch against net-2.6, and this one is against net-next-2.6
>
> Please respin this for me, thanks Jeff.
> --
>

Doh! Sorry Dave.  My bad, respinning now.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/

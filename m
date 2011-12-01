From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: master device stuck in no-carrier
 state forever when in user-stp mode
Date: Thu, 01 Dec 2011 14:05:48 -0500 (EST)
Message-ID: <20111201.140548.1596323918646956109.davem@davemloft.net>
References: <201111251216.37466.vitas@nppfactor.kiev.ua>
	<20111201104409.2d04ca06@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111201104409.2d04ca06@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Dec 2011 10:44:09 -0800

> On Fri, 25 Nov 2011 12:16:37 +0200
> Vitalii Demianets <vitas@nppfactor.kiev.ua> wrote:
> 
>> When in user-stp mode, bridge master do not follow state of its slaves, so 
>> after the following sequence of events it can stuck forever in no-carrier 
>> state:
>> 1) turn stp off
>> 2) put all slaves down - master device will follow their state and also go in 
>> no-carrier state
>> 3) turn stp on with bridge-stp script returning 0 (go to the user-stp mode)
>> Now bridge master won't follow slaves' state and will never reach running 
>> state.
>> 
>> This patch solves the problem by making user-stp and kernel-stp behavior 
>> similar regarding master following slaves' states.
>> 
>> Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>
> 
> This method works fine. David please apply to -net.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Done.

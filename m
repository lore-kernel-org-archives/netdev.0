From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Reset IPCB on forward non-local
 packets in br_handle_frame_finish()
Date: Wed, 02 Nov 2011 16:16:50 -0400 (EDT)
Message-ID: <20111102.161650.1738310866527255233.davem@davemloft.net>
References: <20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
	<CAPDOV48k=0c1anx7DC57u0x84tUVsFDQNO6=MiT+9eEE=Egi2A@mail.gmail.com>
	<20111102131445.28a92335@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, vvs@parallels.com, devel@openvz.org
To: shemminger@vyatta.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111102131445.28a92335@nehalam.linuxnetplumber.net>
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
Date: Wed, 2 Nov 2011 13:14:45 -0700

> On Wed, 2 Nov 2011 13:45:29 -0600
> Daniel Robbins <drobbins@funtoo.org> wrote:
> 
>> On Wed, Nov 2, 2011 at 1:31 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
>> >
>> > What kernel version are you using? There were several previous fixes
>> > in br_netfilter to deal with this type of issue over the last year.
>> 
>> It's a kernel from this obscure company called Red Hat, and they
>> include it in this product called Red Hat Enterprise Linux 6.
>> 
>> Specifically, 042stab37.1 :)
>> 
>> -Daniel
> 
> The pay for their tech support and have them fix it.
> BTW - the problem was fixed upstream a long time ago, the upstream
> kernel moves fast and RHEL probably froze many months before their
> release.

So the original patch not only wasn't build tested, the submitter also
didn't even check if upstream even _had_ the bug to begin with.

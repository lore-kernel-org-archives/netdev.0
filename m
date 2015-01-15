From: Jesse Gross <jesse@nicira.com>
Subject: Re: [linux-nics] [PATCHv4 net] i40e: Implement ndo_gso_check()
Date: Wed, 14 Jan 2015 18:24:34 -0800
Message-ID: <CAEP_g=8iRKx9HPf0KRt6m=6pqAuMeT8_9GM8L+uFe+bMoxk33Q@mail.gmail.com>
References: <1417804872-58635-1-git-send-email-joestringer@nicira.com>
 <1417806738.2404.42.camel@jtkirshe-mobl> <CAEP_g=8mS=P2U_vU2ZMEBUkU8jWo5t2P0h9kxF_jbzJhExAZ9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"linux.nics" <linux.nics@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=8mS=P2U_vU2ZMEBUkU8jWo5t2P0h9kxF_jbzJhExAZ9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 26, 2014 at 3:58 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Dec 5, 2014 at 2:12 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> On Fri, 2014-12-05 at 10:41 -0800, Joe Stringer wrote:
>>> ndo_gso_check() was recently introduced to allow NICs to report the
>>> offloading support that they have on a per-skb basis. Add an
>>> implementation for this driver which checks for IPIP, GRE, UDP
>>> tunnels.
>>>
>>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>>> ---
>>> v4: Simplify the check to just do tunnel header length.
>>>     Fix #define style issue.
>>> v3: Drop IPIP and GRE (no driver support even though hw supports it).
>>>     Check for UDP outer protocol for UDP tunnels.
>>> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>>>     Add MAX_INNER_LENGTH (as 80).
>>> ---
>>>  drivers/net/ethernet/intel/i40e/i40e_main.c |   12 ++++++++++++
>>>  1 file changed, 12 insertions(+)
>>
>> Thanks Joe, I will update the patch in my queue with your latest
>> version.
>
> Jeff, as a heads-up, this patch and the corresponding one for fm10k
> will no longer apply now that the ndo has changed. This was changed by
> 5f35227e ("net: Generalize ndo_gso_check to ndo_features_check"). The
> update needed is trivial and is just due to the change in the function
> signature but I'm not sure where you are in the testing process with
> this.

Jeff - just wanted to check if you had seen this.

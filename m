From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 11:42:23 +0300
Message-ID: <519B336F.9090108@linux.intel.com>
References: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130521.001444.1361294042663568537.davem@davemloft.net>
	<CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
	<20130521.013912.96249995742935192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, or.gerlitz@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com,
	jesse.brandeburg@intel.com, eliezer@tamir.org.il,
	linux-kernel@vger.kernel.org, andi@firstfloor.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130521.013912.96249995742935192.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 21/05/2013 11:39, David Miller wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Tue, 21 May 2013 11:24:41 +0300
>
>> On Tue, May 21, 2013 at 10:14 AM, David Miller <davem@davemloft.net> wrote:
>>> From: "Eilon Greenstein" <eilong@broadcom.com>
>>> Date: Tue, 21 May 2013 10:06:43 +0300
>>>
>>>> Hopefully this series will be accepted so we can send follow up support
>>>> for the bnx2x as well.
>>>
>>> I think in two or three more iterations it will be merged.
>>>
>>> There are no objections on the fundamentals, it's just implementation
>>> details and coding style at this point.
>>
>> Dave, sorry, I might be a bit behind the rest of the reviewers, but I
>> just fail to understand nor find any reference that explains the
>> module param of ixgbe nor it makes sense to me to merge that piece of
>> the code upstream (its not for staging, correct?), as I wrote here
>> http://marc.info/?l=linux-netdev&m=136908123432072&w=2 basically, I
>> know you're not a great fun of module params (to say the least) and
>> surely not something named  "allow_unsafe_removal", thoughts?
>
> It's one of those "implementation details", I hate it too.

I'm open to suggestions.

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

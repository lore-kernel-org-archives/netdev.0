From: Patrick McHardy <kaber@trash.net>
Subject: Re: Current Git: BUG: unable to handle kernel paging
	request at 0000000001a40ca0
Date: Thu, 24 Jul 2008 15:51:43 +0200
Message-ID: <488888EF.4090005@trash.net>
References: <488750AA.20707@gmx.de>	
	<19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com>	
	<48877200.9040608@gmx.de> <4887A860.6070607@gmx.de>	
	<19f34abd0807231500m3d780d90i39626023e0685369@mail.gmail.com>	
	<48882687.7020508@gmx.de>
	<84144f020807240649ra4ef475x9f19f1474678ea2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vegard Nossum <vegard.nossum@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dieter Ries <clip2@gmx.de>,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	Ingo Molnar <mingo@elte.hu>, jgarzik@pobox.com
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <84144f020807240649ra4ef475x9f19f1474678ea2f@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Pekka Enberg wrote:
> On Thu, Jul 24, 2008 at 9:51 AM, Dieter Ries <clip2@gmx.de> wrote:
>> I think I managed to catch one of those:
>>
>> general protection fault: 0000 [1] SMP
>> CPU 0
>> Modules linked in:
>> Pid: 0, comm: swapper Not tainted 2.6.26-06373-gcaf076e #49
>> RIP: 0010:[<ffffffff805e08f9>]  [<ffffffff805e08f9>]
>> nf_nat_move_storage+0x21/0x7a
>> ...
>> Call Trace:
>>  <IRQ>  [<ffffffff8059d3c4>] __nf_ct_ext_add+0x15f/0x1f7
>>  [<ffffffff805e762c>] nf_nat_fn+0x84/0x152
>>  [<ffffffff805e77d8>] nf_nat_in+0x2f/0x71
> Dieter, can you please try this patch:
> 
> http://lkml.org/lkml/2008/7/24/186
> 
> Patrick, it looks like this could be the same bug Ingo is hitting?

Yes, that most likely the same underlying problem.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/

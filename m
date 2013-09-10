From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/26] bonding: use neighbours instead of own
 lists
Date: Tue, 10 Sep 2013 19:08:49 +0800
Message-ID: <522EFDC1.7050002@huawei.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:54563 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab3IJLL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 07:11:27 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/9/10 4:16, Veaceslav Falico wrote:
> (David, feel free to drop the whole patchset - I know that the window is
> closed and I'm quite sure that it's not the last version, and even if it is
> - I'll easily re-submit it. Sorry for the mess :-/)
> 
> Hi,
> 
> RFC -> v1:
> I've added proper, consistent naming for all variables/functions, uninlined
> some helpers to get better backtraces, just in case (overhead is minimal,
> no hot paths), rearranged patches for better review, dropped bondings
> ->prev and bond_for_each_slave_continue() functionality - to be able to
> RCUify it easier, and renamed slave_* sysfs links to lower_* sysfs links to
> maintain upper/lower naming. I've also dropped, thanks to bonding cleanup,
> some heavy and ugly/intrusive patches.
> 
> I'm sending it as early as possible, because it's quite a big patchset and
> some of the approaches I've chosen are not really easy/straightforward.
> It's, however, quite heavily tested already and works fine.
> 
> I'm sending it to gather any feedback possible.
> 
> This patchset introduces all the needed infrastructure, on top of current
> adjacent lists, to be able to remove bond's slave_list/slave->list. The
> overhead in memory/CPU is minimal, and after the patchset bonding can rely
> on its slave-related functions, given the proper locking. I've done some
> netperf benchmarks on a vm, and the delta was about 0.1gbps for 35gbps as a
> whole, so no speed fluctuations.
> 
> It also automatically creates lower/upper and master symlinks in dev's
> sysfs directory.

reviewed, and can't found any problem till now, but it is a big changes,
and I could not sure whether it is the trend of the future for net device,
I'll wait and see everyone's opinion.

Best Regards
Ding

> .
> 

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: Fix the bug when destroy macvlan dev port
Date: Thu, 14 Aug 2014 10:38:30 -0700
Message-ID: <1408037910.6804.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53EC7D8C.6060908@huawei.com>
	 <CAHA+R7MarK5Jx4ZVmyAnQp-DZ6aRNi=rqd3aKBW7OnB8YWsrbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55337 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbaHNRic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 13:38:32 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2020632pab.30
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 10:38:31 -0700 (PDT)
In-Reply-To: <CAHA+R7MarK5Jx4ZVmyAnQp-DZ6aRNi=rqd3aKBW7OnB8YWsrbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 09:58 -0700, Cong Wang wrote:
> On Thu, Aug 14, 2014 at 2:12 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> >
> > To fix this problem, we need to check whether the port is exist when calling
> > macvlan_port_destroy(), do nothing if the port has been destroyed yet.
> >
> 
> As I said, this will make the first call of macvlan_port_destroy()
> free the port,
> which was freed by the last one before.
> 
> Why not just revert your change? It doesn't give any benefit.
> --

Yes please, I think patch should be reverted.

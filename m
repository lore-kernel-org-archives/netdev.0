From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] macvlan: Fix the bug when destroy macvlan dev port
Date: Thu, 14 Aug 2014 09:58:21 -0700
Message-ID: <CAHA+R7MarK5Jx4ZVmyAnQp-DZ6aRNi=rqd3aKBW7OnB8YWsrbQ@mail.gmail.com>
References: <53EC7D8C.6060908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57990 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaHNQ6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 12:58:23 -0400
Received: by mail-lb0-f174.google.com with SMTP id c11so1062924lbj.5
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 09:58:21 -0700 (PDT)
In-Reply-To: <53EC7D8C.6060908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 2:12 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>
> To fix this problem, we need to check whether the port is exist when calling
> macvlan_port_destroy(), do nothing if the port has been destroyed yet.
>

As I said, this will make the first call of macvlan_port_destroy()
free the port,
which was freed by the last one before.

Why not just revert your change? It doesn't give any benefit.

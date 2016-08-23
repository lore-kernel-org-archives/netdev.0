From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 17:33:49 +0200
Message-ID: <20160823173349.2b64b466@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
        <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
        <20160822205137.30cda14f@griffin>
        <20160823152805.GA12627@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48164 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751610AbcHWPeA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 11:34:00 -0400
In-Reply-To: <20160823152805.GA12627@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Aug 2016 18:28:05 +0300, Amir Vadai wrote:
> On Mon, Aug 22, 2016 at 08:51:37PM +0200, Jiri Benc wrote:
> > 2. We may run into problems like tx path seeing the metadata_dst that
> >    it should not see. This means either this situation or such
> >    configuration must be prevented somehow.
[...]
> Anyway, this issue is orthogonal to this patchset...

Not really. If it's indeed (2) then such configuration needs to be
rejected. Or metadata_dst freed at an appropriate place. Thus it's
something that needs to be handled by this patchset before the uAPI is
set in stone.

 Jiri

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 07:17:20 -0400
Message-ID: <533408C0.8000608@mojatatu.com>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us> <53334A3F.6020105@mojatatu.com> <20140327072107.GC2845@minipsycho.orion> <5333FD12.9060404@mojatatu.com> <20140327110223.GA1615@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:62965 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbaC0LRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:17:25 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so4069772obc.1
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 04:17:24 -0700 (PDT)
In-Reply-To: <20140327110223.GA1615@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 07:02, Thomas Graf wrote:
> On 03/27/14 at 06:27am, Jamal Hadi Salim wrote:

> There is definitely need beyond an ndo that is capable of
> adding flows. You mention routes. Another example would be
> devices capable of offloading iptables & nft rules.
>

nod.

> But wouldn't you want to introduce an additional ndo to
> cover these?

We could - I just find it distracting at the current thread
of discussion (the openwrt folks for example dont need any
or most of that).

> What speaks against going with what Jiri proposes and adjust
> & extend as needed as we go along?
>

I was hoping we knock these issue one at a time. The noise right
now is around ports and stacking of ports etc. Which in my
opinion is an easier topic to handle.
Jiri's patches on this can always come back in the discussion
later.

cheers,
jamal

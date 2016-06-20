From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Mon, 20 Jun 2016 08:28:31 -0400
Message-ID: <5767E16F.2040902@mojatatu.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion> <57640F2A.7090003@mojatatu.com>
 <9f8e85ac-3e96-257e-cf7f-e7e793d41cf4@cumulusnetworks.com>
 <20160617154243.GD1981@nanopsycho.orion> <57642F76.6090403@gmail.com>
 <CAJieiUhFRp6wE_gt-0q9KYQTYdEyg5yFUYa89K+ovaQr7QE5Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33113 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbcFTM2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 08:28:35 -0400
Received: by mail-io0-f182.google.com with SMTP id t74so120615458ioi.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 05:28:35 -0700 (PDT)
In-Reply-To: <CAJieiUhFRp6wE_gt-0q9KYQTYdEyg5yFUYa89K+ovaQr7QE5Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-19 11:14 PM, Roopa Prabhu wrote:
> On Fri, Jun 17, 2016 at 10:12 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:


>
> I have also mentioned this before, the default api must provide
> accumulated (hw and sw) stats...,
> because this is the api that the user queries on an interface.

Sorry - I missed those discussions.
What is current practise? Do people request for one via ip link
stats and the other via ethtool?
What do you guys do in your implementation?
Yes, it would be more accurate to provide aggregated stats but
it may break backward compat if expectation is both are read
separately today.
Maybe it makes sense to have a brand new TLV for these aggregated
stats as Jiri was suggesting.That means two new TLVs not one.
1) TLV for aggregated stats - which cant be current one
2) TLV for h/w stats

The existing stat implies s/ware only.

cheers,
jamal

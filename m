From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 17:59:56 -0400
Message-ID: <53349F5C.8090205@mojatatu.com>
References: <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <CAGVrzcbBq2=DG198NnpSWu52+uuundqQ-6QiiuzHF5X_j8fcZw@mail.gmail.com> <20140326173536.GJ2869@minipsycho.orion> <CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com> <20140326181436.GL2869@minipsycho.orion> <53334BDA.1060608@mojatatu.com> <CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com> <20140327065616.GA2845@minipsycho.orion> <CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com> <20140327165550.GN2845@minipsycho.orion> <CAHNKnsRrb1ZoV0he0jLjJ3TBRScHcs6XRxiXrscHRJ6X3=VuGQ@mail.gmail.com> <CAGVrzcZ5JpTZFTMkhLOoh8GMWPDitn=gsVkPLv7rpD3fH3kavQ@mail.gmail.com> <53349C6C.6050506@mojatatu.com> <CAGVrzcY5rhyu3KC2PQd0X+xdBB1D2yJhhPWntLRNoOhTSfDvoQ@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33480 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359AbaC0WAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:00:00 -0400
Received: by mail-ob0-f172.google.com with SMTP id wm4so5035478obc.17
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 14:59:59 -0700 (PDT)
In-Reply-To: <CAGVrzcY5rhyu3KC2PQd0X+xdBB1D2yJhhPWntLRNoOhTSfDvoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 17:54, Florian Fainelli wrote:
> 2014-03-27 14:47 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:

> I think it is. There is nothing in-tree that actually uses that
> feature (switch chaining), but all the infrastructure is there to:
>
> - represent links between switches, which one is cascaded from which
> one and get a sense of their addressing within the switch tree
> - a function call to get that cascading table to programmed to each switch
> - get all relevant "uplink/downlink" switch ports to be configured appropriately
>

Sounds like we have a winner on this aspect at least.
Is it a common setup to have such cascading though - or is this some
overzelous way of solving cascading switches within a LAN?

cheers,
jamal

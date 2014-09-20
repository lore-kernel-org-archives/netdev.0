From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 06:19:38 -0400
Message-ID: <541D54BA.6070709@mojatatu.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com> <541CAB9A.3040100@mojatatu.com> <20140920081702.GF1821@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:46544 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbaITKTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 06:19:43 -0400
Received: by mail-ie0-f173.google.com with SMTP id tr6so4953459ieb.4
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 03:19:43 -0700 (PDT)
In-Reply-To: <20140920081702.GF1821@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 04:17, Jiri Pirko wrote:

> Yes, that I say. It is needed for flow manipulation, because such api does
> not exist.

Come on Jiri!
The ovs guys are against this and now no *api exists*?
Write a 15 tuple classifier tc classifier and use it. I will be more
than happy to help you. I will get to it when we have basics L2 working
on real devices.

>As I stated earlier, I do not want to use switchdev genl for
> anything other than flow manipulation.


Totally unacceptable in my books. If the OVS guys want some way out
to be able to ride on some vendor sdks then that is their problem.
We shouldnt allow for such loopholes. This is why/how TOE never made it
in the kernel.

cheers,
jamal

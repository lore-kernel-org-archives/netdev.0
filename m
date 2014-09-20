From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 06:31:12 -0400
Message-ID: <541D5770.3080305@mojatatu.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541CF75C.9030209@cumulusnetworks.com> <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:64184 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaITKbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 06:31:17 -0400
Received: by mail-ig0-f178.google.com with SMTP id r10so431235igi.17
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 03:31:17 -0700 (PDT)
In-Reply-To: <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 04:10, Scott Feldman wrote:
>
> On Sep 19, 2014, at 8:41 PM, Roopa Prabhu <roopa@cumulusnetworks.com>=
 wrote:
>

>
> Existing rtnetlink isn=92t available to swdev without some kind of sn=
ooping the echoes from the various kernel components
>(bridge, fib, etc).

You have made this claim before Scott and I am still not following.
Why do we need to echo things to get FDB or FIB to work? device ops for=
=20
=46DB offload for example already exist. I think they need to be
revamped, but that consensus can be reasonably reached. Why do we
need this flow api for such activities?

cheers,
jamal

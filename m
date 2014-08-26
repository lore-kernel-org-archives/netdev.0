From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 10:00:58 -0400
Message-ID: <53FC931A.3020903@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us> <1408637945-10390-11-git-send-email-jiri@resnulli.us> <53F79C54.5050701@gmail.com> <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com> <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org> <53FA01AC.10507@mojatatu.com> <20140825145449.GB30140@casper.infradead.org> <53FB68EB.9060308@mojatatu.com> <20140825221148.GC30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:42624 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbaHZOBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:01:01 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so22424794pdj.0
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:01:00 -0700 (PDT)
In-Reply-To: <20140825221148.GC30140@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/14 18:11, Thomas Graf wrote:
> First of all, thanks for the animated discussion, wouldn't
> want to miss our arguments ;-)
>

Passion is key my friend;-> It is said that ancient Greeks
would ask of a person whose funeral they are thinking to attend
"was s/he passionate in life?" And if the answer is negative
they simply dont show up;->

> On 08/25/14 at 12:48pm, Jamal Hadi Salim wrote:
>> On 08/25/14 10:54, Thomas Graf wrote:

> I would argue that swflow is a superset of a Netlink route. It
> may infact be very useful to extend the API with something that
> understands the Netlink representation of a route and have the
> API translate that to a classifier that can be offloaded.
>

Sorry Thomas, I disagree.
A route has a lot more knobs than just a simple flow representation.
We are talking next hops (of which there could be multiple) etc.
There is no way you can boil that down to a simple flow representation.

>> I would be tagging along with you guys for flows if you:
>> a) allow for different classifiers. This allows me to implement
>> u32 and offload it.
>
> Agreed. What you seem to disagree on is:
>
>   - ndo_add_type1([...])
>   - ndo_add_type2([...])
>   - ndo_add_type3([...])
>
> vs.
>
>   - ndo_add_classifier(type, [...])
>

Only for what you call a "flow" - mostly because you have decided
on the universal classifier (lets call it THEONE).
Implementation-wise, you dont have to pass a type. It could be
a sub-ops() function pointer.


cheers,
jamal

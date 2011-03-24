From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: regression: ip r change mss doesn't work in 2.6.38-git14
Date: Thu, 24 Mar 2011 16:52:41 +0100
Message-ID: <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	<1300980118.3747.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300980118.3747.42.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 24, 2011 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 24 mars 2011 =E0 16:08 +0100, Alessandro Suardi a =E9crit :
>> After fixing the display issue thanks to Chris Wilson, I now have
>> another problem
>> =A0(which didn't exist in 2.6.38-git2); most websites outside of my =
DSL link don't
>> =A0work properly (connection packet goes through, but the page load =
times out
>> =A0within Firefox) unless I do
>>
>> ip r change default via 192.168.1.1 dev eth1 advmss 1400
>>
>> This however doesn't change advmss anymore:
>>
>> [root@duff ~]# ip r
>> default via 192.168.1.1 dev eth1
>> 169.254.0.0/16 dev eth1 =A0scope link =A0metric 1004
>> 192.168.1.0/24 dev eth1 =A0proto kernel =A0scope link =A0src 192.168=
=2E1.8
>> [root@duff ~]# ip r change default via 192.168.1.1 dev eth1 advmss 1=
400
>> [root@duff ~]# ip r
>> default via 192.168.1.1 dev eth1
>> 169.254.0.0/16 dev eth1 =A0scope link =A0metric 1004
>> 192.168.1.0/24 dev eth1 =A0proto kernel =A0scope link =A0src 192.168=
=2E1.8
>
> Indeed, we'll take a look, thanks for the report.
>
> In the time being you can do :
>
> ip ro change default via 192.168.1.1 dev eth1 advmss 1400 mtu 1500

Thanks - this one works for me.

I'm available to test patches if needed, though I have a feeling you
 already have a handle on the issue and won't need that ;)

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")

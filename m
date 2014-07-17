From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [GIT net-next v4] Open vSwitch
Date: Thu, 17 Jul 2014 15:25:45 -0700
Message-ID: <CALnjE+qVf9p7TsBU=S84GUtN5f940T-eWERVP=Zocr8Maupkfw@mail.gmail.com>
References: <1405556263-1653-1-git-send-email-pshelar@nicira.com>
	<20140717.144848.463108059351725505.davem@davemloft.net>
	<20140717.145756.1982098731634690697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:44052 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753664AbaGQWZq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 18:25:46 -0400
Received: by mail-vc0-f174.google.com with SMTP id la4so5843110vcb.5
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 15:25:45 -0700 (PDT)
In-Reply-To: <20140717.145756.1982098731634690697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 2:57 PM, David Miller <davem@davemloft.net> wro=
te:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 17 Jul 2014 14:48:48 -0700 (PDT)
>
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Wed, 16 Jul 2014 17:17:43 -0700
>>
>>> Following patches adds three features to OVS
>>> 1. Add fairness to upcall processing.
>>> 2. Recirculation and Hash action.
>>> 3. Enable Tunnel GSO features.
>>> Rest of patches are bug fixes related to patches from same series.
>>>
>>> v2 series changes first patch according to comment from Dave Miller=
=2E
>>> v3 series changes first patch according to comment from Nikolay Ale=
ksandrov.
>>> v4 series changes recirc patch commit msg.
>>
>> Pulled, thanks.
>
> Actually, reverted, this code doesn't even compile.
>
> net/openvswitch/datapath.c: In function =E2=80=98ovs_dp_process_packe=
t_with_key=E2=80=99:
> net/openvswitch/datapath.c:271:43: error: =E2=80=98key=E2=80=99 undec=
lared (first use in this function)
> net/openvswitch/datapath.c:271:43: note: each undeclared identifier i=
s reported only once for each function it appears in
>
> It would be a strong understatement to say that I'm disappointed at t=
his.
>
> Are you even build testing the tree you are asking me to pull from?  =
This
> means you can't have possibly have functionally tested the code.
>
Yesterday when I created my branch, net-next was not merged with net.
Now you have merged it. That resulted in conflict (due to commit
ad55200734c65a3ec5d0c39d6ea904008baea536) which was silently resolved
and as result you got error.

I did not refreshed my base net-next tree just before sending last
pull request Sorry about that.
I will update my branch to solve conflict send updated pull request.

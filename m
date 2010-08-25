From: Elmar Stellnberger <estellnb@gmail.com>
Subject: block network access for certain users/groups
Date: Wed, 25 Aug 2010 13:09:34 +0200
Message-ID: <AANLkTikru-pmMAnS-dqjYT7xJC_X21rVNBpjg_2LDmWB@mail.gmail.com>
References: <AANLkTin8w74SAe67ZPqPE0Q=0fPpZOHnTCnjAT+AduCY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTin8w74SAe67ZPqPE0Q=0fPpZOHnTCnjAT+AduCY@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please answer my question:
It has not been answered, yet.
Thanks for hints like whether to use DROP or REJECT but please answer
my question!

I wanna be pointed on how to implement a per user package selection.
Something similar pretends to be already implemented if you view the
man page, but
it is only implemented for outgoing packages and it even does not work
correctly
(blocking outgoing ICMP-ping requests but with lynx you can happily
view localhost:631
though the rule is on top and applies to any kind of package (raw,
tcp, udp)). We have
already checked this thouroughly.


I need to block network access for certain users/groups, fully:

iptables -A mychain -m owner --gid-owner blockedusergroup -j REJECT

...drops ping packages in the output chain but lets my user happily
connect to localhost:631 or any other http address. In deed the rule
above is therefore pretty useless.

I need to block ALL incoming and outgoing packages for a certain user/group.
At the moment there is only insufficient blocking for outgoing
packages available.

Can you help me?
What will I have to do to implement network access restrictions on a
per user/group basis?
Logging such packages is already possible. Why is blocking them not?

... and yes I have already checked the whole iptables -L -v.
The rule is there and would have been supposed to work.

Yours,
Elmar Stellnberger

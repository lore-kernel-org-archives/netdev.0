From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1] net-sysfs: expose number of link up/down transitions
Date: Thu, 27 Mar 2014 22:56:10 -0700
Message-ID: <CAGVrzcbW3A5RPibKO=i92dj0815eYV6aFRWhOfXA-KgNAgk9kg@mail.gmail.com>
References: <cover.1395980768.git.decot@googlers.com> <cc4b88e880d31d8d71a5c8872a64c9d665cd097e.1395980768.git.decot@googlers.com>
 <20140328161725.e044dd9417cae3020068f350@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140328161725.e044dd9417cae3020068f350@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-27 22:17 GMT-07:00 Stephen Rothwell <sfr@canb.auug.org.au>:
> Hi David,
>
> On Thu, 27 Mar 2014 21:35:00 -0700 David Decotigny <decot@googlers.com> wrote:
>>
>> Tested:
>>   grep . /sys/class/net/*/count_link_*
>>   + ip link set dev X down/up
>>
>> Signed-off-by: David Decotigny <decot@googlers.com>
>
> It is not a very enlightening commit message.  You should tell us why we
> should add this to the kernel.

This might be useful to detect unstable links for instance, by
measuring how many link transitions you get, which could indicate that
either your NIC or your link partner is at fault.

If possible this should come with a Documentation/ABI/testing/ entry,
quite a lot of network sysfs attributes are lacking one at the moment,
but there is no reason why this should continue.
--
Florian

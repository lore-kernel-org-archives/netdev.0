From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [V2 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Fri, 17 Jul 2015 17:04:10 +0200
Message-ID: <87fv4mn7v9.fsf@vitty.brq.redhat.com>
References: <1436868048-17875-1-git-send-email-decui@microsoft.com>
	<20150715.211916.1258342954251964451.davem@davemloft.net>
	<d1e303ece500475b8e422d55f82fbffd@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	"olaf\@aepfle.de" <olaf@aepfle.de>,
	"gregkh\@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang\@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel\@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stephen\@networkplumber.org" <stephen@networkplumber.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw\@canonical.com" <apw@canonical.com>,
	"pebolle\@tiscali.nl" <pebolle@tiscali.nl>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d1e303ece500475b8e422d55f82fbffd@SIXPR30MB031.064d.mgd.msft.net>
	(Dexuan Cui's message of "Thu, 16 Jul 2015 11:19:01 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dexuan Cui <decui@microsoft.com> writes:

>> From: David Miller
>> Sent: Thursday, July 16, 2015 12:19
>> 
>> From: Dexuan Cui
>> Date: Tue, 14 Jul 2015 03:00:48 -0700
>> 
>> > +	pr_debug("hvsock_sk_destruct: called\n");
>> 
>> Debug logging just to state that a function is called is not appropriate,
>> we have very sophisticated tracing facilities in the kernel that can do
>> that transparently, and more.
>> 
>> Please remove this.
> OK. 
>
>> > +	if (hvsk->channel) {
>> > +		pr_debug("hvsock_sk_destruct: calling vmbus_close()\n");
>> 
>> Likewise, these kinds of debug logs are totally inappropriate.
> OK, I'll remove all the pr_debug() in the patch.
>

I'd suggest we rather use something like net_dbg_ratelimited()
intead. The driver is new so issues are expected. Some debugging may
be useful)

[...]

-- 
  Vitaly

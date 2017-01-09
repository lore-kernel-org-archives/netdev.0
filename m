From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] net: dsa: make "label" property optional for
 dsa2
Date: Mon, 9 Jan 2017 18:58:42 +0100
Message-ID: <20170109175842.GH1862@nanopsycho>
References: <20170108231552.26995-1-vivien.didelot@savoirfairelinux.com>
 <20170109073236.GA1862@nanopsycho>
 <877f6446lp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109151131.GC1862@nanopsycho>
 <87y3yk2q5e.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170109160632.GD1862@nanopsycho>
 <89492624-84f2-ca73-75dd-7fa10819ad09@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Andrey Smirnov <andrew.smirnov@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <89492624-84f2-ca73-75dd-7fa10819ad09@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jan 09, 2017 at 06:42:07PM CET, f.fainelli@gmail.com wrote:
>On 01/09/2017 08:06 AM, Jiri Pirko wrote:
>> Mon, Jan 09, 2017 at 04:45:33PM CET, vivien.didelot@savoirfairelinux.com wrote:
>>> Hi Jiri,
>>>
>>> Jiri Pirko <jiri@resnulli.us> writes:
>>>
>>>>> Extra question: shouldn't phys_port_{id,name} be switchdev attributes in
>>>>
>>>> Again, phys_port_id has nothing to do with switches. Should be removed
>>>> from dsa because its use there is incorrect.
>>>
>>> Florian, since 3a543ef just got in, can it be reverted?
>> 
>> Yes, please revert it. It is only in net-next.
>
>Maybe the use case can be understood before reverting the change. How do
>we actually the physical port number of an Ethernet switch per-port
>network device? The name is not enough, because there are plenty of
>cases where we need to manipulate a physical port number (be it just for
>informational purposes).

Like what?

Why the name is not enough? This is something propagated to userspace
and never used internally in kernel.

Btw, ndo_get_phys_port_id does not give you number, but arbitrary binary.


>
>Should we just amend the existing description of ndo_get_phys_port_id()?
>Should we introduce another ndo for that?
>-- 
>Florian

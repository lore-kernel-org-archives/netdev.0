From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 5/9] net: dsa: mv88e6352: disable mirroring
Date: Tue, 2 Jun 2015 21:12:30 -0400 (EDT)
Message-ID: <1365988647.953084.1433293950168.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-6-git-send-email-vivien.didelot@savoirfairelinux.com> <556DBAAA.4010408@roeck-us.net> <20150602145313.GU22739@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150602145313.GU22739@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter, Andrew,

On Jun 2, 2015, at 10:53 AM, Andrew Lunn andrew@lunn.ch wrote:
On Tue, Jun 02, 2015 at 07:16:10AM -0700, Guenter Roeck wrote:
>> On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>> >Disable the mirroring policy in the monitor control register, since this
>> >feature is not needed.
>> >
>> >Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> 
>> Should this be a separate patch, unrelated to the patch set ?

Indeed, this one is an unrelated patch, sorry.

>> If I understand correctly, this effectively disables IGMP/MLD snooping.
>> I think this warrants an explanation why that it not needed, not just
>> a statement that it is not needed.
> 
> +1
> 
> Especially since we might want to revisit this to implement IGMP/MLD
> snooping in the bridge. The hardware should be capable of it.

This is something I want to disable because I can have several times
gigabit traffic on my ports. This would end up in a bottleneck on the
CPU port. Am I right?

Thanks,
-v

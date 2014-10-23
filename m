From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 06:27:55 -0700
Message-ID: <5449025B.4080600@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-7-git-send-email-linux@roeck-us.net> <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com> <54488CE1.2000106@roeck-us.net> <20141023082444.GA4122@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141023082444.GA4122@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/2014 01:24 AM, Richard Cochran wrote:
> On Wed, Oct 22, 2014 at 10:06:41PM -0700, Guenter Roeck wrote:
>> On 10/22/2014 09:37 PM, Florian Fainelli wrote:
>>> You probably want the number of temperature sensors to come from the
>>> switch driver, and support arbitrary number of temperature sensors?
>>
>> In that case we would need the number of sensors, pass a sensor index,
>> and create a dynamic number of attributes. The code would get much more
>> complex without real benefit unless there is such a chip - and if there is,
>> we can still change the code at that time. I would prefer to keep it simple
>> for now.
>
> Better to do it correctly, right from the start. There *will* be such
> a chip one day, and the person wanting to add it will appreciate the
> solid foundation (even if that person ends up being you ;).
>

That is really a matter of opinion; others say one should only introduce
complex infrastructure into the kernel if and when needed. I don't mind
changing the code to anticipate multiple sensors, but as I said it would
be more complex, obviously I would only have limited means to test it,
and, yes, by nature I tend to be one of the people who prefer to keep
things simple. Before I jump into doing this, I would prefer to get
guidance from the maintainer. David ?

Thanks,
Guenter

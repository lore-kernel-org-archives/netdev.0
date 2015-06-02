From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 02 Jun 2015 07:47:14 -0700
Message-ID: <556DC1F2.1070105@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net> <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com> <556DB283.8080300@roeck-us.net> <20150602134252.GT22739@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel@savoirfairelinux.com, Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150602134252.GT22739@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2015 06:42 AM, Andrew Lunn wrote:
>> Also, we already have cases where the switch is connected to the CPU with
>> more than one Ethernet port. It is easy to imagine that the user of such
>> a system might want to configure two bridge groups.
>
> Hi Guenter
>
> I think that is orthogonal.  Having multiple CPU ports should really
> only be seen as increased throughput with load sharing. It makes no
> different to the basic user use cases. They can all be done with a
> single CPU port, but with less bandwidth.
>

Hi Andrew,

quite possibly, but for my part I usually try not to restrict use cases.
Some people may feel uncomfortable with load sharing and rather use
the separate cpu ports to connect to dedicated external ports on the switch.

Sure, that may reduce overall throughput, but it would provide a cleaner
separation of traffic and guarantee that each of the ports gets its full
bandwidth and is not starved by the other. Yes, I am sure that is all
configurable, but it adds more and more complexity for the user.

Thanks,
Guenter

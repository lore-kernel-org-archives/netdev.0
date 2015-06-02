From: nolan <nolan@cumulusnetworks.com>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 02 Jun 2015 15:31:30 -0700
Message-ID: <556E2EC2.3020104@cumulusnetworks.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com> <556D522E.90607@roeck-us.net> <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel@savoirfairelinux.com, Chris Healy <cphealy@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2015 12:44 AM, Scott Feldman wrote:
> That brings up an interesting point about having multiple bridges with
> the same vlan configured.  I struggled with that problem with rocker
> also and I don't have an answer other than "don't do that".  Or,
> better put, if you have multiple bridge on the same vlan, just use one
> bridge for that vlan.  Otherwise, I don't know how at the device level
> to partition the vlan between the bridges.  Maybe that's what Vivien
> is facing also?  I can see how this works for software-only bridges,
> because they should be isolated from each other and independent.  But
> when offloading to a device which sees VLAN XXX global across the
> entire switch, I don't see how we can preserve the bridge boundaries.

Scott,

I'm confused by this.  I think you're saying this config is problematic:

br0: eth0.100, eth1.100
br1: eth2.100, eth3.100

But this works fine today.

Could you clarify the issue you're referring to?

Thanks,
- nolan

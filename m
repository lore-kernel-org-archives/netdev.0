From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: make the STP state function return void
Date: Tue, 05 Apr 2016 23:16:45 -0400
Message-ID: <87bn5nxw82.fsf@ketchup.mtl.sfl>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20160405234714.GB19409@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405234714.GB19409@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> -- port_stp_update: bridge layer function invoked when a given switch port STP
>> +- port_stp_state: bridge layer function invoked when a given switch port STP
>
> port_stp_state_set might be a better name, to make it clear it is
> setting the state, not getting the current state, etc. Most of the
> other functions are _add, _prepare, _join, _leave, so _set would fit
> the pattern.

I agree, I'm changing that.

> Changing to a void makes sense.

Thanks,
Vivien

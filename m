From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Tue, 29 Aug 2017 08:25:23 +0200
Message-ID: <20170829062523.GA1977@nanopsycho.orion>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828195332.GB1950@nanopsycho.orion>
 <20170828200834.GA1870@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828200834.GA1870@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Aug 28, 2017 at 10:08:34PM CEST, andrew@lunn.ch wrote:
>> I see this overlaps a lot with DPIPE. Why won't you use that to expose
>> your hw state?
>
>We took a look at dpipe and i talked to you about using it for this
>sort of thing at netconf/netdev. But dpipe has issues displaying the
>sort of information we have. I never figured out how to do two
>dimensional tables. The output of the dpipe command is pretty
>unreadable. A lot of the information being dumped here is not about
>the data pipe, etc.

So improve it. No problem. Also, we extend it to support what you neede.


>
>There is a lot of pushback on debugfs for individual drivers. As i
>said recently to somebody, debugfs is a bit of a wild west. When
>designing this code, we thought about that. This debugfs is not at the
>driver level. It is at the DSA level. All DSA drivers will benefit
>from this code, and all DSA drivers will get the same information
>exposed in debugfs. It is generic, well defined and structured, with
>respect to DSA.

Still, it has *a lot* of overlap with devlink and dpipe. So instead of
making devlink and dpipe work for you, you introduced completely
separated debugfs interface specific to a list of drivers. That is just
wrong. Debugfs is never the correct answer! Please work with us on
devlink and dpipe so they are used for all drivers, mlxsw, dsa and others.

Thanks!

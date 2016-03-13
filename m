From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 3/3] net: dsa: refine netdev event notifier
Date: Sun, 13 Mar 2016 09:39:02 -0400
Message-ID: <878u1mlcp5.fsf@ketchup.mtl.sfl>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1457851346-26257-4-git-send-email-vivien.didelot@savoirfairelinux.com> <20160313073250.GA2955@colbert.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160313073250.GA2955@colbert.mtl.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ido,

Ido Schimmel <idosch@mellanox.com> writes:

>>+	case NETDEV_PRECHANGEUPPER:
>
> Why do you need this here? It seems you are always ignoring it in
> dsa_slave_port_upper_event()? Probably better to introduce it when you
> actually need it.
>
> Other than that, it looks good to me.

I've prepare a real v1 without this switch case locally, I'll send it in
a few moment unless there are other comments.

Thanks Ido!
Vivien

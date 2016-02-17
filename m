From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: bridge: log port STP state on change
Date: Tue, 16 Feb 2016 20:27:34 -0800
Message-ID: <20160216202734.4f86a80c@xeon-e3>
References: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Feb 2016 10:09:51 -0500
Vivien Didelot <vivien.didelot@savoirfairelinux.com> wrote:

> Remove the shared br_log_state function and print the info directly in
> br_set_state, where the net_bridge_port state is actually changed.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

Looks good and fixes the weird case where set_state fails then a log
message would still be printed.

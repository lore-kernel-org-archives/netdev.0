From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 03/17] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Wed, 02 Dec 2015 12:31:59 -0500 (EST)
Message-ID: <20151202.123159.1617446027222393431.davem@davemloft.net>
References: <1448921155-24764-4-git-send-email-ddecotig@gmail.com>
        <20151201.221356.2176806670215219133.davem@davemloft.net>
        <CAG88wWbW=yxO0mzauJauEd3W-SuPq3eNGRE+Xe6ATcLKhrPq3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, amirv@mellanox.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-api@vger.kernel.org, linux-mips@linux-mips.org,
        fcoe-devel@open-fcoe.org, edumazet@google.com,
        eugenia@mellanox.co.il, ogerlitz@mellanox.com, idos@mellanox.com,
        joe@perches.com, saeedm@mellanox.com, _govind@gmx.com,
        VenkatKumar.Duvvuru@emulex.com, jeffrey.t.kirsher@intel.com,
        eyalpe@mellanox.com, pshelar@nicira.com,
        eswierk@skyportsystems.com, robert.w.love@intel.com,
        JBottomley@parallels.com, Yuval.Mintz@qlogic.com
To: ddecotig@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <CAG88wWbW=yxO0mzauJauEd3W-SuPq3eNGRE+Xe6ATcLKhrPq3A@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <ddecotig@gmail.com>
Date: Tue, 1 Dec 2015 22:00:58 -0800

> There is a set of conversion routines ulong[]<->u32[] to address this
> 32/64-bit compat issue.

And it's extremely ugly.

There is nothing stopping you from adding bitmap_set32() et al. helpers
to facilitate things.

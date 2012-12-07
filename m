From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] bridge: make buffer larger in br_setlink()
Date: Fri, 07 Dec 2012 14:40:54 -0500 (EST)
Message-ID: <20121207.144054.818881635723246698.davem@davemloft.net>
References: <20121207093107.GA2996@casper.infradead.org>
	<20121207111045.GA9676@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121207111045.GA9676@elgon.mountain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 7 Dec 2012 14:10:46 +0300

> We pass IFLA_BRPORT_MAX to nla_parse_nested() so we need
> IFLA_BRPORT_MAX + 1 elements.  Also Smatch complains that we read past
> the end of the array when in br_set_port_flag() when it's called with
> IFLA_BRPORT_FAST_LEAVE.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.

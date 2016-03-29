From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH] bridge: Allow set bridge ageing time when
 switchdev disabled
Date: Wed, 30 Mar 2016 00:34:13 +0300
Message-ID: <20160329213413.GA2917@colbert.idosch.org>
References: <1459248488-25621-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, jiri@mellanox.com,
	"David S. Miller" <davem@davemloft.net>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1459248488-25621-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
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

Tue, Mar 29, 2016 at 01:48:08PM IDT, yanhaishuang@cmss.chinamobile.com wrote:
>When NET_SWITCHDEV=n, switchdev_port_attr_set will return -EOPNOTSUPP,
>we should ignore this error code and continue to set the ageing time.
>
>Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Fixes: c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")
Acked-by: Ido Schimmel <idosch@mellanox.com>

Thank you.

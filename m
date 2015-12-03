From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Only call /sbin/bridge-stp for the
 initial network namespace
Date: Wed, 02 Dec 2015 23:50:49 -0500 (EST)
Message-ID: <20151202.235049.2068953758962834535.davem@davemloft.net>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
	<87egf7183c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, kernel-hardening@lists.openwall.com, richard@nod.at,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <87egf7183c.fsf_-_@x220.int.ebiederm.org>
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

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 30 Nov 2015 15:38:15 -0600

> +	if (dev_net(br->dev) == &init_net)

Please respin this using net_eq() as Hannes pointed out.

Thanks.

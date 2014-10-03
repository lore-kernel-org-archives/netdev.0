From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v3 net-next 2/3] bridge: Simplify pvid checks.
Date: Fri, 03 Oct 2014 10:11:27 +0900
Message-ID: <542DF7BF.4000408@lab.ntt.co.jp>
References: <1412294070-11930-1-git-send-email-vyasevic@redhat.com>
	<1412294070-11930-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1412294070-11930-3-git-send-email-vyasevic@redhat.com>
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

On 2014/10/03 8:54, Vladislav Yasevich wrote:
> Currently, if the pvid is not set, we return an illegal vlan value
> even though the pvid value is set to 0.  Since pvid of 0 is currently
> invalid, just return 0 instead.  This makes the current and future
> checks simpler.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Thanks,
Toshiaki Makita

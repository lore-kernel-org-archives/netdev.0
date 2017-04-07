From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net: Remove unnecessary cast on void pointer
Date: Fri, 7 Apr 2017 17:27:12 +0200
Message-ID: <20170407152712.GA1466@salvia>
References: <20170328190516.GA19531@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, James Morris <jmorris@namei.org>,
	outreachy-kernel@googlegroups.com, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net
To: simran singhal <singhalsimran0@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170328190516.GA19531@singhal-Inspiron-5558>
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

On Wed, Mar 29, 2017 at 12:35:16AM +0530, simran singhal wrote:
> The following Coccinelle script was used to detect this:
> @r@
> expression x;
> void* e;
> type T;
> identifier f;
> @@
> (
>   *((T *)e)
> |
>   ((T *)x)[...]
> |
>   ((T*)x)->f
> |
> 
> - (T*)
>   e
> )
> 
> Unnecessary parantheses are also remove.

Applied, thanks.

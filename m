From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bridge: Fix format string for %ul
Date: Sat, 27 Aug 2016 18:13:03 +0300
Message-ID: <11e50e3c-2e1f-4614-07e3-3bd144af4f94@cogentembedded.com>
References: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Oleg Drokin <green@linuxhacker.ru>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
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

Hello.

On 8/27/2016 6:10 AM, Oleg Drokin wrote:

> %ul would print an unsigned value and a letter l,
> likely it was %lu that was meant to print the long int,
> but in reality the values printed there are just regular signed

    Signed? Then you need probably "%d" or "%i"...

> ints, so just dropping the l altogether.
>
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
[...]

MBR, Sergei

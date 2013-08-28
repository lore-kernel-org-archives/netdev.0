From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: [PATCH net-next 1/1] net: neighbour: Simplify ifdefs around neigh_app_ns()
Date: Wed, 28 Aug 2013 13:09:26 -0600
Message-ID: <521E4AE6.7080703@canonical.com>
References: <1377714286-51816-1-git-send-email-tim.gardner@canonical.com> <1377715873.1928.47.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377715873.1928.47.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/28/2013 12:51 PM, Joe Perches wrote:
> On Wed, 2013-08-28 at 12:24 -0600, Tim Gardner wrote:
>> Drop a couple of ifdef/endif pairs by moving the ifdef
>> surrounding neigh_app_ns() to the interior of neigh_app_ns().
> []
>> This is an admittedly trivial change. I stumbled on it while trying to figure
>> out why Ubuntu doesn't have CONFIG_ARPD enabled.
> 
> I'd be more inclined to make neigh_app_ns static inline
> in the .h file and remove the EXPORT_SYMBOL
> 

I thought about that as well, but then you'd have to extern
__neigh_notify(), which is currently a static function and large enough
to not really be suitable for inlining. Seems like unnecessary churn to me.

rtg
-- 
Tim Gardner tim.gardner@canonical.com

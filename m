From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] ipv4: netfilter: ipt_CLUSTERIP: fix buffer overflow
Date: Sun, 20 Mar 2011 15:43:36 +0100
Message-ID: <4D861298.1040700@trash.net>
References: <1299780740-32652-1-git-send-email-segoon@openwall.com> <AANLkTimPZJoCzz386e-4m0Y4khWGZirZguGFmuFYCrry@mail.gmail.com> <4D7F5CAC.6070006@trash.net> <20110317113229.GA7710@albatros> <AANLkTimtsB0B98E2xcoJgRsPwSpwuG+ahT+LX0s1YwpX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, security@kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimtsB0B98E2xcoJgRsPwSpwuG+ahT+LX0s1YwpX@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.03.2011 13:15, schrieb Changli Gao:
> On Thu, Mar 17, 2011 at 7:32 PM, Vasiliy Kulikov <segoon@openwall.com> wrote:
>> 'buffer' string is copied from userspace.  It is not checked whether it is
>> zero terminated.  This may lead to overflow inside of simple_strtoul().
>> Changli Gao suggested to copy not more than user supplied 'size' bytes.
>>
>> It was introduced before the git epoch.  Files "ipt_CLUSTERIP/*" are
>> root writable only by default, however, on some setups permissions might be
>> relaxed to e.g. network admin user.
>>
>> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> Acked-by: Changli Gao <xiaosuo@gmail.com>
> 
> 

Applied, thanks everyone.

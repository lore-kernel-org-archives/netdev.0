From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: make ctl_path local and const
Date: Tue, 19 Oct 2010 20:01:41 -0700
Message-ID: <1287543701.10409.599.camel@Joe-Laptop>
References: <1287543276-4511-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, James Morris <jmorris@namei.org>,
        linux-sctp@vger.kernel.org, rds-devel@oss.oracle.com,
        "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>, linux-x25@vger.kernel.org,
        dccp@vger.kernel.org, bridge@lists.linux-foundation.org,
        Andrew@smtp1.linux-foundation.org, coreteam@netfilter.org,
        Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Joerg Reuter <jreuter@yaina.de>, Sridhar Samudrala <sri@us.ibm.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vlad Yasevich <vladislav.yasevich@hp.com>, netfilter@vger.kernel.org,
        Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
        linux-hams@vger.kernel.org,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, linux-kernel@vger.ker
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1287543276-4511-1-git-send-email-xiaosuo@gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-10-20 at 10:54 +0800, Changli Gao wrote:
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
[]
> diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
> index 04e9c0d..b92f269 100644
> --- a/net/appletalk/sysctl_net_atalk.c
> +++ b/net/appletalk/sysctl_net_atalk.c
> @@ -42,16 +42,16 @@ static struct ctl_table atalk_table[] = {
>  	{ },
>  };
>  
> -static struct ctl_path atalk_path[] = {
> -	{ .procname = "net", },
> -	{ .procname = "appletalk", },
> -	{ }
> -};
> -
>  static struct ctl_table_header *atalk_table_header;
>  
>  void atalk_register_sysctl(void)
>  {
> +	const struct ctl_path atalk_path[] = {

Shouldn't all of these be static const struct ?

From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] Fixed to checkpatch.pl errors to vlan_dev.c
Date: Mon, 5 Dec 2016 16:48:13 +0100
Message-ID: <98f13d7e-69e5-a392-bd95-d615dbfcba3f@osg.samsung.com>
References: <52561480952041@web13j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Ozgur Karatas <ozgur@member.fsf.org>, kaber@trash.net,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52561480952041@web13j.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/12/16 16:34, Ozgur Karatas wrote:
> Hello all,
>
> I will solve a checkpatch errors.
>
> Signed-off-by: Ozgur Karatas <ozgur@member.fsf.org>

The patch itself looks good, but please have a read about having a good 
commit message. I would suggest reading Documentation/SubmittingPatches 
section 14: The canonical patch format

Especially the parts about the subject line and summary.

>
> ---
>  net/8021q/vlan_dev.c                               |   2 +-
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index fbfacd5..2edb495 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -738,7 +738,7 @@ static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *n
>
>  static void vlan_dev_netpoll_cleanup(struct net_device *dev)
>  {
> -       struct vlan_dev_priv *vlan= vlan_dev_priv(dev);
> +       struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
>         struct netpoll *netpoll = vlan->netpoll;
>
>         if (!netpoll)
>

regards
Stefan Schmidt

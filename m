From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Fri, 22 May 2015 14:56:36 -0400 (EDT)
Message-ID: <20150522.145636.734827115116283588.davem@davemloft.net>
References: <1432301557-6928-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, wkok@cumulusnetworks.com,
	cwang@twopensource.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1432301557-6928-1-git-send-email-linus.luessing@c0d3.blue>
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

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Fri, 22 May 2015 15:32:37 +0200

> @@ -1786,14 +1784,8 @@ int br_multicast_set_router(struct net_bridge =
*br, unsigned long val)
>  	case 1:
>  		br->multicast_router =3D val;
>  		err =3D 0;
> -		break;
> -
> -	default:
> -		err =3D -EINVAL;
> -		break;
>  	}

Please don't remove the break; statement.

> @@ -1827,14 +1817,8 @@ int br_multicast_set_port_router(struct net_br=
idge_port *p, unsigned long val)
>  			break;
>  =

>  		br_multicast_add_router(br, p);
> -		break;
> -
> -	default:
> -		err =3D -EINVAL;
> -		break;
>  	}
>  =

> -unlock:
>  	spin_unlock(&br->multicast_lock);
>  =

>  	return err;

Likewise.

Thanks.

From: YOSHIFUJI Hideaki <yoshfuji@hongo.wide.ad.jp>
Subject: Re: [PATCH] Missing break in switch statement.
Date: Tue, 12 Aug 2003 02:14:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812.021414.128414948.yoshfuji@hongo.wide.ad.jp>
References: <E19mFqr-00068T-00@tetrachloride>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, davej@redhat.com
In-Reply-To: <E19mFqr-00068T-00@tetrachloride>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <E19mFqr-00068T-00@tetrachloride> (at Mon, 11 Aug 2003 17:48:57 +0100), davej@redhat.com says:

> Is this intentional? It should at least have a 
> /* FALLTHROUGH */ or similar if so.

Of course not.

>  		else
>  			val = opt->offset;
> +		break;
>  
>  	default:
>  		return -ENOPROTOOPT;

agreed.

--yoshfuji

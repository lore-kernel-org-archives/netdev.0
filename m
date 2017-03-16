From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/5] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 16 Mar 2017 15:27:07 -0700
Message-ID: <1489703227.28631.253.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
         <20170316183250.15806.59426.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183250.15806.59426.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 11:32 -0700, Alexander Duyck wrote:

>  
> +	case SO_INCOMING_NAPI_ID:
> +		v.val = sk->sk_napi_id;
> +		break;

I guess that here you should filter invalid values.

(So that you no longer need the first patch in this series)

Also, it looks like eBPF will need to get access to skb->napi_id for
efficient SO_REUSEPORT support ?

Thanks.

From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 9/9] net: batman-adv: use per_cpu_add helper
Date: Fri, 2 Nov 2012 17:48:04 +0000
Message-ID: <0000013ac23ca1c8-740e6cfa-8166-4369-80d6-88bdfa8117d6-000000@email.amazonses.com>
References: <5093EE7E.6040400@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	ordex@autistici.org, b.a.t.m.a.n@lists.open-mesh.org,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5093EE7E.6040400@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Nov 2012, Shan Wei wrote:

> diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
> index 897ba6a..3aef5b2 100644
> --- a/net/batman-adv/main.h
> +++ b/net/batman-adv/main.h
> @@ -263,9 +263,7 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
>  static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
>  				      size_t count)
>  {
> -	int cpu = get_cpu();
> -	per_cpu_ptr(bat_priv->bat_counters, cpu)[idx] += count;
> -	put_cpu();
> +	this_cpu_add(bat_priv->bat_counters[idx], count);
>  }

Reviewed-by: Christoph Lameter <cl@linux.com>

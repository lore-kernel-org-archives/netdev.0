From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 3/8] S2io: optimizations
Date: Thu, 14 Oct 2004 10:46:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E9142.8030006@pobox.com>
References: <004601c4b18b$2ee81a30$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <004601c4b18b$2ee81a30$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Hi,
> Following are the optimization-related changes made in this patch.


No objections to this patch, but did I miss a description of the 
following change?

> -       if ((sp->pkt_cnt[ring] - rxb_size) > 128) {
> +       if ((sp->pkt_cnt[ring] - rxb_size) > 16) {
>                 level = LOW;
> -               if (rxb_size < sp->pkt_cnt[ring] / 8)
> +               if ((sp->pkt_cnt[ring] - rxb_size) < MAX_RXDS_PER_BLOCK) {
>                         level = PANIC;
> +               }
>         }

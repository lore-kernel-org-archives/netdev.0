From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Thu, 14 Oct 2004 11:03:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E9550.4060001@pobox.com>
References: <005a01c4b18b$c1fd7400$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <005a01c4b18b$c1fd7400$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

no objections but two comments:

1) can this not be done with SKB fragments?

2) the following code needlessly uses GFP_ATOMIC:

> +                               ba = &nic->ba[i][j][k];
> +
> +                               ba->ba_0_org = (void *) kmalloc
> +                                   (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);

and there is another example just a bit down from that one.

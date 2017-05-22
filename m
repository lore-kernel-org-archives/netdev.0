From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 2/5] sctp: Delete an error message for a failed memory
 allocation in sctp_init()
Date: Mon, 22 May 2017 16:59:43 -0400
Message-ID: <0937b8d5-bf8c-81c5-af58-0c7a629b7932@redhat.com>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <7db0cb49-109b-88a6-532f-c591cc8ffa85@users.sourceforge.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7db0cb49-109b-88a6-532f-c591cc8ffa85@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2017 12:38 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 17:28:14 +0200
> 
> Omit an extra message for a memory allocation failure in this function.
> 
> This issue was detected by using the Coccinelle software.
> 
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/sctp/protocol.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 2b1a6215bd2f..5e7c8a344770 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1447,5 +1447,4 @@ static __init int sctp_init(void)
>  	if (!sctp_ep_hashtable) {
> -		pr_err("Failed endpoint_hash alloc\n");
>  		status = -ENOMEM;
>  		goto err_ehash_alloc;
>  	}
> 

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

At the time this was written, it was patterned after TCP.  Since then TCP changed
significantly.  We can surely clean-up the pr_err() here and possibly update the
code as well later.

-vlad

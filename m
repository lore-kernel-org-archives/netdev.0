From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv2.1] net: wireless: iwlwifi: remove minor dead code
Date: Tue, 12 Nov 2013 07:24:04 +0200
Message-ID: <5281BB74.50903@gmail.com>
References: <1384110397-24386-1-git-send-email-mpn@google.com> <527FDB50.1050902@cogentembedded.com> <87iow080zv.fsf@mina86.com> <1384177312.14334.12.camel@jlt4.sipsolutions.net> <xa1tr4amwkrt.fsf@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <xa1tr4amwkrt.fsf-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 11/12/2013 02:01 AM, Michal Nazarewicz wrote:
> inta is checked to be zero in a IRQ_NONE branch so afterwards it
> cannot be zero as it is never modified.
> 
> Signed-off-by: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/wireless/iwlwifi/pcie/rx.c | 24 +++++++++---------------
>  1 file changed, 9 insertions(+), 15 deletions(-)
> 
> On Mon, Nov 11 2013, Johannes Berg wrote:
>> no signed-off-by
> 
> Sorry, fixed.  Interestingly, I did not forget about it in my first patch.
> 

no worries - I picked it up in our internal tree.
Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

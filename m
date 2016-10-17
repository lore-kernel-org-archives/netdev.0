From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re:
 linux-4.9-rc1/drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c:1561: poor
 error checking ?
Date: Mon, 17 Oct 2016 10:58:33 +0300
Message-ID: <1476691113.3880.37.camel@coelho.fi>
References: <VI1PR08MB1022786893DC435E1A71F3069CD00@VI1PR08MB1022.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Binderman <dcb314-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
        "johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR08MB1022786893DC435E1A71F3069CD00-Rgw4eRhbCXnvbuUDGEufgykoKrxaZxrJvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,
On Mon, 2016-10-17 at 07:40 +0000, David Binderman wrote:
> Hello there,
> 
> linux-4.9-rc1/drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c:1561]: (style) Checking if unsigned variable 'len' is less than zero.
> 
> Source code is
> 
>     len = min((size_t)le32_to_cpu(rsp->len) << 2,
>           iwl_rx_packet_payload_len(hcmd.resp_pkt) - sizeof(*rsp));
>     len = min(len - delta, count);
>     if (len < 0) {
>         ret = -EFAULT;
>         goto out;
>     }
> 
> Suggest improve error checking.

Thanks for reporting! A fix for this is already queued in our internal
tree and will be sent upstream soon.

--
Cheers,
Luca.

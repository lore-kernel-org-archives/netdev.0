From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] brcmfmac: Ensure pointer correctly set if skb data
 location changes
Date: Tue, 25 Apr 2017 09:56:37 +0200
Message-ID: <17dd69e6-1438-3474-aa0a-6c44e68855a5@broadcom.com>
References: <20170424114050.24948-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170424114050.24948-1-james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 24-4-2017 13:40, James Hughes wrote:
> The incoming skb header may be resized if header space is
> insufficient, which might change the data adddress in the skb.
> Ensure that a cached pointer to that data is correctly set by
> moving assignment to after any possible changes.

Hi Kalle,

This one should go on 4.12 queue as well.

Thanks,
Arend

> Signed-off-by: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
> 
> Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---

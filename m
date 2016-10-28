From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Ignore VHT IE from peer with wrong rx_mcs_map
Date: Fri, 28 Oct 2016 17:46:00 +0200
Message-ID: <1477669560.4220.1.camel@sipsolutions.net>
References: <1477665523-8970-1-git-send-email-filip.matusiak@tieto.com>
         (sfid-20161028_163919_221476_0288EF78)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: marek.kwaczynski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Filip Matusiak <filip.matusiak-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477665523-8970-1-git-send-email-filip.matusiak-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org> (sfid-20161028_163919_221476_0288EF78)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-28 at 16:38 +0200, Filip Matusiak wrote:
> This is a workaround for VHT-enabled STAs which break the spec
> and have the VHT-MCS Rx map filled in with value 3 for all eight
> spacial streams.
> 
> As per spec, in section 22.1.1 Introduction to the VHT PHY
> A VHT STA shall support at least single spactial stream VHT-MCSs
> 0 to 7 (transmit and receive) in all supported channel widths.

Interesting, and also kinda dumb :)

> +	/*
> +	 * This is a workaround for VHT-enabled STAs which break the
> 

I find that it helps, in the future, if we know an example of a station
that did this, so we can test other implementations etc. Can you change
the comment accordingly?

johannes

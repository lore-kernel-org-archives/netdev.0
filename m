From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Thu, 08 Jul 2010 23:51:56 -0400
Message-ID: <4C369CDC.9080104@signal11.us>
References: <1276467601-9066-1-git-send-email-alan@signal11.us> <1278623485.10421.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1278623485.10421.73.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/08/2010 05:11 PM, Marcel Holtmann wrote:
> I looked at this and I am bit worried that this should not be done in
> this detail in the HIDP driver. Essentially HIDP is a pure transport
> driver. It should not handle all these details. Can we make this a bit
> easier for the transport drivers to support such features?
>
> Regards
>
> Marcel
>    

Hi Marcel,

I put these changes (most notably the addition of hidp_get_raw_report()) 
in hidp because that's where the parallel function 
hidp_output_raw_report() was already located. I figured the input should 
go with the output. That said, if there's a better place for both of 
them (input and output) to go, let me know where you think it should be, 
and I'll get them moved into the proper spot.

I'm not sure what you mean about HIDP being a pure transport driver.

Alan.

From: Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH linux-next v3] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 22:40:20 -0500
Message-ID: <513EA3A4.4070100@opengridcomputing.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com> <1363036508-24935-1-git-send-email-tim.gardner@canonical.com> <20130311212535.GG642@fieldses.org> <513E6271.3060107@opengridcomputing.com> <513E989E.8060206@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <513E989E.8060206-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Ah....Ok

On 3/11/13 9:53 PM, Tim Gardner wrote:
> On 03/11/2013 05:02 PM, Tom Tucker wrote:
>> On 3/11/13 4:25 PM, J. Bruce Fields wrote:
>
> <snip>
>
>>> Looks good to me; wish we could get it tested....
>>
>> I will test it. Tim could you please send me a final version that you'd
>> like tested as a single message?
>>
>
> I'm a little confused about what you are asking. I think v3 of the patch 
> is the final version (unless you find bugs with it).
>
>> Would someone (like Tim maybe ... hint hint) look at tearing out all
>> those dead registration strategies? I don't think we need or will ever
>> use bounce-buffers, memory windows, or mlnx fmr.  The only two that are
>> used and tested are all-phys and FRMR (the default).
>>
>
> Dunno if I'll get time for that. I had a one day window where I could 
> hack out some simple patches. Now I'm back to the usual grindstone.
>
> rtg

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

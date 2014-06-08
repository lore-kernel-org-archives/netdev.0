From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: hw.c: Cleaning up
 conjunction always evaluates to false
Date: Sun, 08 Jun 2014 10:45:50 -0500
Message-ID: <5394852E.1000601@lwfinger.net>
References: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <1436639.AmJiDmeQZF@al> <CAFo99gb2gzLjv_4b3O-e0B1R8P5BTGbPJLuYYAmoyww9hkmrvA@mail.gmail.com> <3239222.FyGtueg2aO@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Peter Wu <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>,
	Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3239222.FyGtueg2aO@al>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/08/2014 05:43 AM, Peter Wu wrote:
> On Sunday 08 June 2014 12:36:11 Rickard Strandqvist wrote:
>> Then we use MSR_MASK instead, new patch then. But I will wait a day?
>> Or what is long enough to be sure that nobody else have any
>> objections? How is this usually resolved?
>
> Well, Larry is the maintainer, so he will ultimately pick up patches.
> One or two days should give people some time to read and reply.

My role as maintainer is a little different than others. As I have a private 
broadband connection with only 1 Mbps upload, it is not practical for me to 
operate a git server. I used to have an account at kernel.org, but I lost it 
after the break-in there. As I have never met face-to-face with another Linux 
developer, I have had no chance to have my credentials signed, so that resource 
is unavailable. As a result, I ACK or NACK patches and they are picked up by 
John Linville for drivers in the regular wireless tree, and Greg Kroah-Hartman 
for the staging drivers.

> As for MSR_MASK, that macro does not exist yet, I was wondering whether
> it's OK to add a new macro? (Larry?)

Yes, that is OK.

>> Sure, I can send a patch for all the files instead. However, earlier
>> received complaints when I sent patches extending over more than one
>> file.

These do really need to be split a little. There must be at least one patch for 
the wireless tree, and a second for staging. In fact, I prefer the way they are 
with one for each driver.

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

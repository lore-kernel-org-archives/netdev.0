From: Luis de Bethencourt <luisbg-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] ath: fix macros coding style issue in regd.c
Date: Tue, 30 Mar 2010 00:39:18 +0100
Message-ID: <506b70dc1003291639j4a620ef0ve551d97bea26fa2e@mail.gmail.com>
References: <1269904339-15599-1-git-send-email-luisbg@ubuntu.com>
	 <1269905624.4558.56.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1269905624.4558.56.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 12:33 AM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> On Tue, 2010-03-30 at 00:12 +0100, Luis de Bethencourt wrote:
>> This is a patch to the ath/regd.c file that fixes up three warnings
>> about macros found by the checkpatch.pl tool, these said that
>> complex values should be enclosed in parenthesis.
>
> Hi Luis.
>
> Checkpatch isn't always correct.
>
> Please make sure to compile test your changes
> before submitting them.
>
> These macros are used as initializers and
> can not be surrounded by parentheses.
>
> =A0 =A0 =A0 =A0.reg_rules =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ATH9K_2GHZ_ALL,
>
> cheers, Joe
>
>

Hi Joe,

Sorry about this. I compiled test the changes but make didn't complain.

My bad, will try to avoid this better in the future.

Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

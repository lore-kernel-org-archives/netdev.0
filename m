From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Sun, 27 Mar 2011 17:47:36 -0500
Message-ID: <4D8FBE88.3050907@lwfinger.net>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>	<4D8E5BA3.1090909@users.sourceforge.net> <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com> <4D8E8B1E.3030709@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wu zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roman Mamedov <rm-pzoh41kZ4TQvJsYlp49lxw@public.gmane.org>
To: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D8E8B1E.3030709-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/26/2011 07:55 PM, Hin-Tak Leung wrote:
> wu zhangjin wrote:
>> On Sun, Mar 27, 2011 at 5:33 AM, Hin-Tak Leung
>> <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> wrote:
>>> Wu Zhangjin wrote:
>>>> led can not be turned off normally when rfkill is blocked, the cause is
>>>> the led_turn_off() function exit as not expected:
>>> Hmm. While this sounds more sensible, is it needed? And what does the
>>> windows driver do?
>>>
>>> I think there are two kind of LEDs - one that comes on and off with the
>>> rfkill switch; Larry or Herton makes the 2nd one, if there is one, blink
>>> while there is traffic (and stay steady on otherwise).
>>
>> I have used this driver on the YeeLoong netbook(only support Linux),
>> there is only one LED for rtl8187, when there is traffic, it blinks
>> perfectly, but If press the hotkey to turn off the rf, the network
>> interface is down, but the LED is still light, then, the users may
>> mistakenly think the hotkey or rfkill support doesn't work or simply
>> think the interface is still on. So, that's why we may need to fix it.
>
> My laptop (a Toshiba one) has the other kind of LED - the LED only comes on and
> off in relation to the rfkill switch, and does not blink with traffic. I think
> Herton or Larry has some devices with both types.
>
> Hmm, I seem to have the impression that there is code somewhere for switching a
> singular LED's behavior of the driver between one or the other, by echo'ing into
> sysfs or some other trickery? Or would that be a desired approach if that's not
> done at the moment?

My rtl8187 devices are both external USB sticks, thus they have no interaction 
with a radio-kill switch. I will test your patch to make sure it does no harm to 
my system.

I think the commit message should be revised. A simple statement like "the LED 
does not turn off when the rfkill switch is off" should be sufficient.

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

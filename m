From: Dirk <biecie547@gmail.com>
Subject: Re: Slow connection with RTL8168b/8111b
Date: Sat, 24 Feb 2007 20:56:02 +0100
Message-ID: <88ab4080702241156pc77b2aexe383d11ac1ec3473@mail.gmail.com>
References: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com>
	 <20070222080633.GA6612@electric-eye.fr.zoreil.com>
	 <88ab4080702240315r320a0adeq4baa6d8fb140f22b@mail.gmail.com>
	 <20070224114147.GA2282@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Edward Hsu" <edward_hsu@realtek.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:6822 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933548AbXBXT4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 14:56:03 -0500
Received: by wx-out-0506.google.com with SMTP id h31so867033wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 11:56:03 -0800 (PST)
In-Reply-To: <20070224114147.GA2282@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/24/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Thanks for testing.
>
> Can you try the patch below on top of:
>
> http://www.fr.zoreil.com/people/francois/misc/20070223-2.6.21-rc1-r8169-test.patch
>
> Don't hurry: it's saturday. :o)
>
> ... removed patch itself...

I applied both patches (*test.patch and the one you included in your
email) but unfortunately it makes no difference (only tested NAPI
enabled driver).

I noticed the same slow behaviour also in a ssh session with midnight
commander. Once I press Enter to enter a directory in mc, there is a
small delay (only a fraction of a second) between pressing the key and
the update of the screen. When I floodping the ssh serverhost, the
response is instantly.

Are there any additional tests I can do that would be helpfull to you?


Kind regards,
Dirk

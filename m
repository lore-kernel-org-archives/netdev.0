From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 14:55:55 +0200
Message-ID: <87r6a0eg10.fsf@macbook.be.48ers.dk>
References: <87mykoircs.fsf@macbook.be.48ers.dk>
	<200807111400.38312.oliver@neukum.org>
	<87vdzcehs9.fsf@macbook.be.48ers.dk>
	<200807111422.56406.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807111422.56406.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> (Oliver Neukum's message of "Fri\, 11 Jul 2008 14\:22\:55 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>>> "Oliver" == Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:

Hi,

 >> Ahh. So kmalloc() / kfree() around the usb_control_msg isn dm_read /
 >> dm_write is the way to go?

 Oliver> The buffer should be allocated with kmalloc. That doesn't
 Oliver> mean it has to be allocated each time the function is
 Oliver> called. If several drivers do this, the best fix is to modify
 Oliver> struct usbnet so that it contains only a pointer to the
 Oliver> buffer, not the buffer itself and modify drivers accordingly.

Ok, but this is just for a few config registers - Nothing in the fast
path, so I'll keep it simple.

-- 
Bye, Peter Korsgaard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

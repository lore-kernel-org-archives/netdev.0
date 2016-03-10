From: Peter Korsgaard <peter-+2lRwdCCLRT2eFz/2MeuCQ@public.gmane.org>
Subject: Re: [PATCH 1/3] dm9601: enable EP3 interrupt
Date: Thu, 10 Mar 2016 22:55:14 +0100
Message-ID: <87twkej8vx.fsf@dell.be.48ers.dk>
References: <1457609014-3597-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Joseph Chang <joseph_chang-Ubu6M+hUeUGoECsaD+WFmw@public.gmane.org>
To: Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457609014-3597-1-git-send-email-josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Joseph
	CHANG's message of "Thu, 10 Mar 2016 19:23:34 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>>> "Joseph" == Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

 > Enable chip's EP3 interrupt to get the link-up notify soon
 > immediately.

Sorry, what do you mean about 'soon immediately'?

 > +
 > +		/* Always return 8-bytes data to host per interrupt-interval */
 > +		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);

Why would we want to do that instead of the current setup that afaik
only returns data when the link status changes?

-- 
Bye, Peter Korsgaard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

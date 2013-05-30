From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH V3.10] rtlwifi: rtl8192cu: Fix problem in connecting to
 WEP or WPA(1) networks
Date: Fri, 31 May 2013 07:13:39 +0900
Message-ID: <20130530221339.GA1630@kroah.com>
References: <1369949040-9513-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1369949040-9513-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 30, 2013 at 04:23:30PM -0500, Larry Finger wrote:
> Driver rtl8192cu can connect to WPA2 networks, but fails for any other
> encryption method. The cause is a failure to set the rate control data
> blocks. These changes fix https://bugzilla.redhat.com/show_bug.cgi?id=952793
> and https://bugzilla.redhat.com/show_bug.cgi?id=761525.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
> 
> John,
> 
> This patch is pretty large for this stage; however, it fixes a bad bug, and
> it will only affect rtl8192cu even though it touches rtlwifi.
> 
> I held it for a while while Fedora and RHEL users tried it and responded.
> As you well know, that can take a while.


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

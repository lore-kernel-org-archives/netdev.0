From: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 06:39:59 -0800
Message-ID: <1326119999.13074.369.camel@wwguy-huron>
References: <4F065F59.2070107@intel.com>
	 <1325843269.3330.4.camel@jlt3.sipsolutions.net>
	 <4F0A3C62.6010403@intel.com> <1326069251.13074.360.camel@wwguy-huron>
	 <4F0A492A.5080504@intel.com>  <1326071127.13074.367.camel@wwguy-huron>
	 <1326100270.3451.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Yan, Zheng" <zheng.z.yan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1326100270.3451.5.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-01-09 at 10:11 +0100, Johannes Berg wrote:
> On Sun, 2012-01-08 at 17:05 -0800, Guy, Wey-Yi wrote:
> 
> 
> > I understand, but unless we figure out either make rkill interrupt works
> > in runtime PM, or figure out the platform does not has HW RFKILL
> > automatically, I don't see how this patch can upstream without generate
> > a lot of issues and bug reports.
> 
> I suppose the question is -- will any tools/users enable it and then
> scream about their rfkill?
> 
> Maybe we can use pm_runtime_forbid() to disable it completely, and add a
> module parameter or something to enable it -- just so people are aware
> of the tradeoffs?

module parameter shall works, we just need a clear and easy way to allow
user enable/disable this runtime PM feature and not making mistake

Wey
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

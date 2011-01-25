From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Date: Mon, 24 Jan 2011 19:53:04 -0600
Message-ID: <4D3E2D00.8050007@parallels.com>
References: <1295012954-7769-1-git-send-email-kas@openvz.org> <20110124235545.GA793@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	<containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110124235545.GA793-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/24/2011 05:55 PM, Kirill A. Shutemov wrote:
> On Fri, Jan 14, 2011 at 03:48:58PM +0200, Kirill A. Shutemov wrote:
>> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
>> Only for client for now.
>>
>> It's step forwart to get nfs work from container.
> 
> Any feedback?

I didn't see anything to object to, and I'll give a:

Reviewed-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

To the one that you rewrote for me (um, 12/16).  I still don't
understand at the design level why init_rpc_pipefs exists if containers
don't need it, but it seems to be implementing what it sets out to do.

But it doesn't apply to my test environment (nfsv3 unauthenticated), and
I'm still trying to finish up that before switching gears to look at v4.

Rob
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

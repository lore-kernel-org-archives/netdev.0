From: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] iwl3945: queue the right work if the scan needs to be
 aborted
Date: Mon, 27 Sep 2010 08:13:58 +0200
Message-ID: <20100927081358.07b30327@schatten.dmk.lab>
References: <1285345323-4250-1-git-send-email-florian@mickler.org>
	<1285357868.12594.8.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Cahill, Ben M" <ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285357868.12594.8.camel@wwguy-ubuntu>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2010 12:51:08 -0700
"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:

> Hi Florian,
> 
> Thanks for sending the patch, the scan operation in iwlwifi just being
> modified and the changes you have no longer apply.please check the
> latest kernel.
> 
> Thanks
> Wey
> 

Ok, I checked out
git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-2.6.git
and it definitely looks better in there. This patch shouldn't be
necessary for that. 

Do you plan on submitting this for 2.6.36 or .37?

I think my patch should fix the instance reported in the bug in a less
invasive manner. 
Only remaining question is why it did only show up now. But that's
probably due to the workqueue changes.


Regards,
Flo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

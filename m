From: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Mon, 18 Jul 2016 18:27:15 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD11013920461D@DFRE01.ent.ti.com>
References: <20160628104305.4533-1-yanivma@ti.com>
 <87eg6qx2ou.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Hahn, Maital" <maitalm-l0cyMroinI0@public.gmane.org>, Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"Mishol, Guy" <guym-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87eg6qx2ou.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 20:42:57, Kalle Valo wrote:
> Guy; Johannes Berg; Arik Nemtsov; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; 
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH] wlcore/wl18xx: mesh: added initial mesh support 
> for wl8
> 
> Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org> writes:
> 
> > From: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> >
> > 1. Added support for interface and role of mesh type.
> > 2. Enabled enable/start of mesh-point role,
> >    and opening and closing a connection with a mesh peer.
> > 3. Added multirole combination of mesh and ap
> >    under the same limits of dual ap mode.
> > 4. Add support for 'sta_rc_update' opcode for mesh IF.
> >    The 'sta_rc_update' opcode is being used in mesh_plink.c.
> > Add support in wlcore to handle this opcode correctly for mesh (as 
> > opposed to current implementation that handles STA only).
> > 5. Bumped the firmware version to support new Mesh functionality
> >
> > Signed-off-by: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> > Signed-off-by: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
> 
> Does this depend on any mac80211 patches? To not break anything I 
> can't apply this until all the dependencies are in my tree.
> 

Hi Kalle,
No, there are no dependencies for this patch.
The other set of patches are bug fixes and improvements, shouldn't block the merge.

Thanks,
Yaniv


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

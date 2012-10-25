From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next 00/15] 6lowpan: Some more
	bug fixes
Date: Thu, 25 Oct 2012 11:10:37 -0400
Message-ID: <5089566D.6000801@signal11.us>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
	<CAJmB2rDcdo7r-0xoNnrbXRB4KKWoKJmpu9OTk5HHuE1V5Py2qA@mail.gmail.com>
	<383f66ae460548de6f930b0f1c244e5a@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <383f66ae460548de6f930b0f1c244e5a-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/25/2012 10:49 AM, Tony Cheneau wrote:
>  I'm not so OK with removing patch 15, or at least, it would require
> some more testing in other parts of the code. Basically, the TBD are
> placeholder for when the Association Request/Response will be
> reimplemented. I introduced it because otherwise, .assoc_req and
> .assoc_resp entries of mac802154_mlme_wpan would go uninitialized and
> would cause kernel crash when called. I could have modified the
> calling code to deal with that, but I thought these primitives were
> meant to be re-implemented soon anyway.

I think just simply stating this in the commit message would fix the
issue here. Maybe something like "Fix crash where assoc_req() and
assoc_resp() were not defined."

This should probably get split into two patches, one for BSN and the
other for assoc.

Also, make the bsn functions static, and the convention is to put static
functions above where they are being used, so that you don't have to
forward declare them. It looks though, like this source file doesn't do
that for other functions, so maybe following the convention of this file
for now is ok.

Alan.


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct

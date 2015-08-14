From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/2] average: provide macro to create static EWMA
Date: Fri, 14 Aug 2015 08:44:12 +0200
Message-ID: <1439534652.2091.0.camel@sipsolutions.net>
References: <1439457109-21833-1-git-send-email-johannes@sipsolutions.net>
	 <20150813.172655.794541030036505262.davem@davemloft.net>
	 (sfid-20150814_022700_456030_2C423706)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150813.172655.794541030036505262.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20150814_022700_456030_2C423706)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-13 at 17:26 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Thu, 13 Aug 2015 11:11:48 +0200
> 
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > 
> > Having the EWMA parameters stored in the runtime struct imposes
> > memory requirements for the constant values that could just be
> > inlined in the code. This particularly makes sense if there are
> > a lot of such structs, for example in mac80211 in the station
> > table where each station has a number of these in an array, and
> > there can be many stations.
> > 
> > Provide a macro DECLARE_EWMA() that declares the necessary struct
> > and inline functions to access it with the parameters hard-coded;
> > using this also means the user no longer needs to 'select AVERAGE'
> > as it's entirely self-contained.
> > 
> > In the mac80211 case, on x86-64, this actually slightly *reduces*
> > code size, while also saving 80 bytes of runtime memory per sta.
> > 
> > Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > ---
> > As the next patch relies on this, I'll take this through my tree
> > unless I hear objections.
> 
> This looks fine to me.
> 

Thanks, I've applied both.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

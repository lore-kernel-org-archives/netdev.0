From: Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Wed, 31 Aug 2011 09:47:19 +1200
Message-ID: <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com> <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com> <4E5CEC79.3090802@freedesktop.org>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E5CEC79.3090802-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 31/08/2011, at 1:58 AM, Jim Gettys wrote:

> On 08/29/2011 11:42 PM, Adrian Chadd wrote:
>> On 30 August 2011 11:34, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> 
>> C(P) is going to be quite variable - a full frame retransmit of a 4ms
>> long aggregate frame is SUM(exponential backoff, grab the air,
>> preamble, header, 4ms, etc. for each pass.)
>> 
> It's not clear to me that doing heroic measures to compute the cost is
> going to be worthwhile due to the rate at which the costs can change on
> wireless; just getting into the rough ballpark may be enough. But
> buffering algorithms and AQM algorithms are going to need an estimate of
> the *time* it will take to transmit data, more than # of bytes or packets.

That's not heroic measures; mac80211 needs all the code to calculate these times anyway, it's just a matter of collecting together some things we already know and calling the right function.

Andrew--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

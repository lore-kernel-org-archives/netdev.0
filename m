From: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PERF RESULTS] virtio and vhost-net performance
	enhancements
Date: Thu, 26 May 2011 21:59:10 +0530
Message-ID: <OF75734CC8.5E488020-ON6525789C.005A0CF6-6525789C.005A4B7B@in.ibm.com>
References: <cover.1305846412.git.mst@redhat.com>
	<OF0EFA7BA9.BB2C2860-ON6525789C.0053EE3A-6525789C.005513CC@in.ibm.com>
	<OFE30C8D78.526FF88D-ON8725789C.00563B8C-8825789C.0056469F@us.ibm.com>
	<OFF9D0E604.B865A006-ON6525789C.00597010-6525789C.0059987A@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Steve Dobbelstein <steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <OFF9D0E604.B865A006-ON6525789C.00597010-6525789C.0059987A@LocalDomain>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2/India/IBM wrote on 05/26/2011 09:51:32 PM:

> > Could you please try TCP_RRs as well?
>
> Right. Here's the result for TCP_RR:

The actual transaction rate/second numbers are:

_____________________________________________________________
#     RR1      RR2 (%)          SD1        SD2 (%)
_____________________________________________________________
1     9476     9903 (4.5)       28.9       19.8 (-31.4)
2     17337    18225 (5.1)      92.7       83.7 (-9.7)
4     17385    27902 (60.4)     364.8      315.8 (-13.4)
8     25560    42912 (67.8)     1428.1     1234.0 (-13.5)
16    35898    55934 (55.8)     4391.6     4038.1 (-8.0)
32    48048    80228 (66.9)     17391.4    14932.0 (-14.1)
64    60412    88929 (47.2)     71087.7    54230.1 (-23.7)
96    71263    92439 (29.7)     145434.1   128214.0 (-11.8)
128   84208    91014 (8.0)      233668.2   238888.6 (2.2)
_____________________________________________________________
RR: 37.3%     SD: -6.7%
_____________________________________________________________

Thanks,

- KK

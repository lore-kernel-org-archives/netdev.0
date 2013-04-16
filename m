From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH v3] vxlan: Allow setting destination to unicast address.
Date: Tue, 16 Apr 2013 09:46:36 +0300
Message-ID: <CAF1J0HNo=8CE0mMbWGrS4xqeivaZ8WTMwb=R92UP2rtH_ngLEQ@mail.gmail.com>
References: <87hajcm7ym.wl%atzm@stratosphere.co.jp>
	<OF3CF233D4.68C04252-ON85257B4E.006F940A-85257B4E.0072C761@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Atzm Watanabe <atzm@stratosphere.co.jp>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:43866 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754153Ab3DPGqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 02:46:37 -0400
Received: by mail-ob0-f200.google.com with SMTP id tb18so1014890obb.11
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 23:46:36 -0700 (PDT)
In-Reply-To: <OF3CF233D4.68C04252-ON85257B4E.006F940A-85257B4E.0072C761@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 11:53 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 04/12/2013 05:09:05 AM:
>
>> From: Atzm Watanabe <atzm@stratosphere.co.jp>
>
>> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
>> ---
>
> If this is turned into a vxlan_rdst, it should check for other
> attributes to fill that-- PORT, VNI, IFINDEX-- with approprate
> default values if not present.
>
> Overall, this patch looks ok to me as far as it goes, but I think
> it'd be more useful if it were more generic; that is, if it supported
> everything an fdb can.

I've just sent an rfc patch that is slightly more generic version of
Atzm Watanabe work (1). It makes the "default destination" a list of
destinations rather than a single entry.
If the approach seems Ok, I can extend it to do "everything an fdb can".


(1) http://thread.gmane.org/gmane.linux.network/265871

>                                                         +-DLS
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Sincerely yours,
Mike.

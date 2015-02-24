From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 24 Feb 2015 11:24:55 +0100
Message-ID: <1424773495.2192.23.camel@sipsolutions.net>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	 <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	 <1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	 <CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
	 <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
	 <1423577962.2215.2.camel@sipsolutions.net>
	 <CA+BoTQn=YQQ_yUHvpAG3MMAw+=jxgLDiUMWxiTC3B3vkksTw9g@mail.gmail.com>
	 <CA+BoTQnxo-x94uVfErZO43jTowVcEMEt+7xDzoAGiR8fRDv=ug@mail.gmail.com>
	 (sfid-20150212_084824_976893_36D95ADD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eyal Perry <eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQnxo-x94uVfErZO43jTowVcEMEt+7xDzoAGiR8fRDv=ug-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20150212_084824_976893_36D95ADD)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-02-12 at 08:48 +0100, Michal Kazior wrote:

> > Good point. I was actually thinking about it. I can try cooking a
> > patch unless you want to do it yourself :-)
> 
> I've taken a look into this. The most obvious place to add the
> timestamp for each packet would be ieee80211_tx_info (i.e. the
> skb->cb[48]). The problem is it's very tight there. Even squeezing 2
> bytes (allowing up to 64ms of tx completion delay which I'm worried
> won't be enough) will be troublesome. Some drivers already use every
> last byte of their allowance on 64bit archs (e.g. ar5523 uses entire
> 40 bytes of driver_data).

Couldn't we just repurpose the existing skb->tstamp field for this, as
long as the skb is fully contained within the wireless layer?

Actually, it looks like we can't, since I guess timestamping options can
be turned on on any socket.

> I wonder if it's okay to bump skb->cb to 56 bytes to avoid the cascade
> of changes required to implement the tx completion delay accounting?

I have no doubt that would be rejected :)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [BUG] in skge.c on 2.6.18-rc5
Date: Wed, 30 Aug 2006 19:36:56 +0200
Message-ID: <7d01f9f00608301036m621149bt82b4c007a6432a6@mail.gmail.com>
References: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com>
	 <7d01f9f00608301021v5d02b18dg8b0d993ee3dd1977@mail.gmail.com>
	 <20060830102916.0e64e3b5@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:45437 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751201AbWH3Rg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:36:57 -0400
Received: by py-out-1112.google.com with SMTP id n25so371999pyg
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 10:36:56 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060830102916.0e64e3b5@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Wed, 30 Aug 2006 19:21:20 +0200
> "Thibaut VARENE" <T-Bone@parisc-linux.org> wrote:
>
> > Replying to myself as I've been pointed at Stephen's reply (please CC
> > me, i'm not subscribed):
> >
> > I'm bringing the interface up with 'dhclient eth0', and yes it's using autoneg.
> >
>
> Any chance of getting a backtrace; serial port, digital camera, handwritten note?

If you can deal with this extremely blurry shot:
http://www.pateam.org/archive/tmp/IMGP0825.JPG

begins with "mod_timer" / "neigh_update" / "read_lock" and so on.

Worst case I'll reproduce the bug again and dump a better bt, but I'd
rather avoid as much as possible as I use that machine a lot right now
;P

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/

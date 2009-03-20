From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 09:16:18 -0700
Message-ID: <20090320091618.2604ad53@nehalam>
References: <20090320.005205.65922171.davem@davemloft.net>
	<49C35443.8020604@cn.fujitsu.com>
	<20090320.013448.251351318.davem@davemloft.net>
	<87prgcju7v.fsf@nemi.mork.no>
	<20090320141949.GA1031@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QmrDuHJu?= Mork <bjorn@mork.no>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40864 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757816AbZCTQQZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 12:16:25 -0400
In-Reply-To: <20090320141949.GA1031@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009 15:19:50 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> Fri, Mar 20, 2009 at 12:43:00PM CET, bjorn@mork.no wrote:
> >David Miller <davem@davemloft.net> writes:
> >> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> >> Date: Fri, 20 Mar 2009 16:30:59 +0800
> >>
> >>> David Miller wrote:
> >>> > Committed to net-next-2.6...
> >>> >=20
> >>> > sunvnet: Convert to net_device_ops.
> >>>=20
> >>> I noticed that there are other drivers's  net_device_ops=20
> >>> need to be converted,is these convert nessary?
> >>
> >> Not necessary, but desirable.  Once all drivers are
> >> converted we can remove the compatability code.
> >
> >Just thinking... Would it make sense, at some point before removing =
the
> >compatibility layer, to add tests for partial conversions?  I notice=
d
> >the sungem bug just fixed by Stephen Hemminger=20
> >( http://permalink.gmane.org/gmane.linux.network/122756 )
> >which could have been caught by the patch below.
> >
> >This will also ease the transition of "driver sets", like usbnet and
> >it's children, where a number of drivers need to make the conversion
> >together.  Don't know if that's a big problem, but it did stop my fi=
rst
> >attempt to convert usbnet because I was uncertain whether I had caug=
ht
> >all of the necessary mini driver conversions.
> >
> >Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> >---

I intend to get all drivers in x86 allmodconfig converted, then
change expose the COMPAT_NETDEV_OPS as a config option (which is how
I test). Need to wait until after in tree drivers all converted
because kernel developers expect random configurations to build.

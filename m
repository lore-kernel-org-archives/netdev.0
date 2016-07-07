From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 7 Jul 2016 17:48:09 +0200
Message-ID: <20160707154809.GN620@orbyte.nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org>
 <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org>
 <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58359 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbcGGPsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 11:48:11 -0400
Content-Disposition: inline
In-Reply-To: <577E5244.8030601@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 02:59:48PM +0200, Nicolas Dichtel wrote:
> Le 07/07/2016 13:17, Phil Sutter a =C3=A9crit :
> [snip]
> > The issue came up during OpenStack Neutron testing, see this ticket=
 for
> > reference:
> >=20
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D1310795
> Access to this ticket is not public :(

*Sigh* OK, here are a few quotes:

"OpenStack Neutron controller nodes, when undergoing testing, are
locking up specifically during creation and mounting of namespaces.
They appear to be blocking behind vfsmount_lock, and contention for the
namespace_sem"

"During the scale testing, we have 300 routers, 600 dhcp namespaces
spread across four neutron network nodes. When then start as one set of
standard Openstack Rally benchmark test cycle against neutron. An
example scenario is creating 10x networks, list them, delete them and
repeat 10x times. The second set performs an L3 benchmark test between
two instances."

Cheers, Phil
